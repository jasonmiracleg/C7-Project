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
    
    private var speechManager = SpeechManager()
    
    var isRecording: Bool {
        speechManager.isRecording
    }
    
    var isDraftMode: Bool {
        !transcriptDraft.isEmpty && !isRecording
    }
    
    private let story: StoryDetail
    
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
        cancelDraft()
        
        isWaitingForAIResponse = true
        print("--- AI PROSES NEXT FOLLOW UP QUESTION (Mic Disabled) ---")
        
        getDummyAIResponse()
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
}
