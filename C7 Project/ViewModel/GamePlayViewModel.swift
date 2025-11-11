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
    
//    view models for evaluation
    var interpretationViewModel = InterpretationEvaluationViewModel()
    
    private let story: StoryDetail
    private var speechManager = SpeechManager()
    private let followUpGenerator = FollowUpQuestion()
    
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
    }
    
    func onAppear() {
        requestPermissions()
        addInitialPrompt()
    }
    
    func startRecording() {
        do {
            try speechManager.startRecording()
            print("--- START RECORDING ---")
        } catch {
            print("ERROR: FAILED TO START RECORDING: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        speechManager.stopRecording()
        print("--- STOP RECORDING ---")
        self.transcriptDraft = speechManager.transcript
    }
    
    func cancelDraft() {
        print("--- DRAFT CANCELED ---")
        self.transcriptDraft = ""
        speechManager.transcript = ""
    }
    
    func sendMessage() {
        let messageText = transcriptDraft
        guard !messageText.isEmpty else { return }
        
        print("--- MESSAGE SENT ---")
        
        chatHistory.append(ChatMessage(text: messageText, isSent: true))
        interpretationViewModel.appendAnswer(messageText)
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
            interpretationViewModel.appendPrompt(story.initialPrompt)
        }
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
            interpretationViewModel.appendPrompt(followUp)
            
            if chatHistory.count > 6 {
                isFinished = true
            }
        } catch {
            print("[Follow-Up Generation Error]: \(error)")
        }
        
        isWaitingForAIResponse = false
    }

}
