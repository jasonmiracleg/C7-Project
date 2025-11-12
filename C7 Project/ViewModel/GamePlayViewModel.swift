//
//  GamePlayViewModel.swift
//  C7 Project
//
//  Created by Maria Angelica Vinesytha Chandrawan on 05/11/25.
//

import Foundation
import SwiftUI

@Observable
class GameplayViewModel {
    
    var chatHistory: [ChatMessage] = []
    var transcriptDraft: String = ""
    var isFinished: Bool = false
    var isWaitingForAIResponse: Bool = false
    var permissionsGranted: Bool = false
    var timeDisplay: String = "01.00"
    var canStopRecording: Bool = false
    var isTimeRunningOut: Bool = false
    
    private let story: StoryDetail
    private var speechManager = SpeechManager()
    private let followUpGenerator = FollowUpQuestion()
    private var timer: Timer?
    private var secondsElapsed: Int = 0
    private let maxRecordTime: Int = 60
    private let minRecordTime: Int = 15
    private let warningTime: Int = 15
    
    var isRecording: Bool {
        speechManager.isRecording
    }
    
    var isDraftMode: Bool {
        !transcriptDraft.isEmpty && !isRecording
    }
    
    var lastAIQuestion: String? {
        // Second to last from chatHistory
        guard chatHistory.count >= 2 else { return nil}
        
        let AImessage = chatHistory[chatHistory.count - 2]
        
        // isSent must be false
        return !AImessage.isSent ? AImessage.text : nil
    }
    
    var lastUserAnswer: String? {
        // Last message from chatHistory
        guard let lastMessage = chatHistory.last else { return nil }
        
        return lastMessage.isSent ? lastMessage.text : nil
    }
    
    init(story: StoryDetail) {
        self.story = story
        self.timeDisplay = formatTime(maxRecordTime)
    }
    
    func onAppear() {
        requestPermissions()
        addInitialPrompt()
    }
    
    func startRecording() {
        do {
            try speechManager.startRecording()
            print("--- START RECORDING ---")
            
            secondsElapsed = 0
            canStopRecording = false
            timeDisplay = formatTime(maxRecordTime)
            
            isTimeRunningOut = false
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.onTimerTick()
            }
        } catch {
            print("ERROR: FAILED TO START RECORDING: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        timer?.invalidate()
        timer = nil
        
        speechManager.stopRecording()
        print("--- STOP RECORDING ---")
        self.transcriptDraft = speechManager.transcript
    }
    
    func cancelDraft() {
        print("--- DRAFT CANCELED ---")
        self.transcriptDraft = ""
        speechManager.transcript = ""
        
        resetTimerDisplay()
    }
    
    func sendMessage() {
        let messageText = transcriptDraft
        guard !messageText.isEmpty else { return }
        
        print("--- MESSAGE SENT ---")
        
        chatHistory.append(ChatMessage(text: messageText, isSent: true))
        cancelDraft()
        
        isWaitingForAIResponse = true
        
        Task {
            print("--- AI PROSES NEXT FOLLOW UP QUESTION (Mic Disabled) ---")
            await generateFollowUpQuestion()
        }
    }
    
    private func requestPermissions() {
        speechManager.requestPermissions { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionsGranted = granted
            }
        }
    }
    
    private func addInitialPrompt() {
        if chatHistory.isEmpty {
            chatHistory.append(ChatMessage(text: story.initialPrompt, isSent: false))
        }
    }
    
    private func getDummyAIResponse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = "That’s great! What kind of tools did you implement to improve the workflow?"
            print("AI RESPONSE: \(aiResponse)")
            self.chatHistory.append(ChatMessage(text: aiResponse, isSent: false))
            
            if self.chatHistory.count > 3 {
                print("--- CONVERSATION DONE ---")
                self.isFinished = true
            }
            
            self.isWaitingForAIResponse = false
        }
    }
    
    private func onTimerTick() {
        secondsElapsed += 1
        
        let remainingTime = maxRecordTime - secondsElapsed
        timeDisplay = formatTime(remainingTime)
        
        if secondsElapsed >= minRecordTime {
            canStopRecording = true
        }
        
        if remainingTime <= warningTime {
                    isTimeRunningOut = true
                }
        
        if secondsElapsed >= maxRecordTime {
            print("Times Up...")
            stopRecording()
        }
        
    }
    private func resetTimerDisplay() {
        timeDisplay = formatTime(maxRecordTime)
        secondsElapsed = 0
        canStopRecording = false
        isTimeRunningOut = false
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        let mm = String(format: "%02d", minutes)
        let ss = String(format: "%02d", remainingSeconds)
        return "\(mm).\(ss)"
    }
    
    @MainActor
    private func generateFollowUpQuestion() async {
        print("DEBUG CHAT HISTORY:")
        for (index, msg) in chatHistory.enumerated() {
            print("[\(index)] \(msg.text) | isSent: \(msg.isSent)")
        }
        
        print("DEBUG lastAIQuestion:", lastAIQuestion ?? "nil")
        print("DEBUG lastUserAnswer:", lastUserAnswer ?? "nil")
        
        
        guard let previousAI = lastAIQuestion,
              let lastUserAnswer = lastUserAnswer else {
            isWaitingForAIResponse = false
            return
        }
        
        // Optional delay if you want to simulate AI thinking
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 sec
        
        do {
            let followUp = try await followUpGenerator.generateFollowUpQuestion(
                scenario: story.storyContext,   // ✅ scenario context stays here
                question: previousAI,
                userAnswer: lastUserAnswer
            )
            
            chatHistory.append(ChatMessage(text: followUp, isSent: false))
            
            if chatHistory.count > 6 {
                isFinished = true
            }
        } catch {
            print("[Follow-Up Generation Error]: \(error)")
        }
        
        isWaitingForAIResponse = false
    }
    
}
