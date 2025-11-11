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
    
    var isModelLoading: Bool {
        speechManager.isModelLoading
    }
    
    var modelLoadError: String? {
        speechManager.modelLoadError
    }
    
    var isDraftMode: Bool {
        !transcriptDraft.isEmpty && !isRecording
    }
    
    var lastAIQuestion: String? {
        guard chatHistory.count >= 2 else { return nil }
        let AImessage = chatHistory[chatHistory.count - 2]
        return !AImessage.isSent ? AImessage.text : nil
    }
    
    var lastUserAnswer: String? {
        guard let lastMessage = chatHistory.last else { return nil }
        return lastMessage.isSent ? lastMessage.text : nil
    }
    
    init(story: StoryDetail) {
        self.story = story
        
        // Setup transcript callback
        speechManager.onTranscriptUpdate = { [weak self] transcript in
            guard let self = self else { return }
            Task { @MainActor in
                self.transcriptDraft = transcript
                print("📝 Draft updated via callback: \(transcript)")
            }
        }
    }
    
    func onAppear() {
        requestPermissions()
        addInitialPrompt()
        
        // Load WhisperKit model
        Task {
            await speechManager.loadModel()
        }
    }
    
    func startRecording() {
        guard !isModelLoading else {
            print("⚠️ Model still loading...")
            return
        }
        
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
        
        // Poll for transcript updates
        Task {
            // Wait for transcription to complete
            for _ in 0..<20 { // Poll for up to 2 seconds
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec
                
                await MainActor.run {
                    let currentTranscript = speechManager.transcript
                    if !currentTranscript.isEmpty && currentTranscript != self.transcriptDraft {
                        self.transcriptDraft = currentTranscript
                        print("📝 Draft updated: \(currentTranscript)")
                        return
                    }
                }
                
                // Break early if we got a transcript
                if !self.transcriptDraft.isEmpty {
                    break
                }
            }
        }
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
            print("--- AI PROCESS NEXT FOLLOW UP QUESTION (Mic Disabled) ---")
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
        
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 sec
        
        do {
            let followUp = try await followUpGenerator.generateFollowUpQuestion(
                scenario: story.storyContext,
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
