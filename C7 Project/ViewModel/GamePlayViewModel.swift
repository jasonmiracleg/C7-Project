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
    
//    view models for evaluation
    var interpretationViewModel = InterpretationEvaluationViewModel()
    
    private let story: StoryDetail
    private var speechManager = SpeechManager()
    private let followUpGenerator = FollowUpQuestion()
    private var timer: Timer?
    private var secondsElapsed: Int = 0
    private let maxRecordTime: Int = 60
    private let minRecordTime: Int = 15
    private let warningTime: Int = 15
    
    // Evaluation view models
    var grammarViewModel = GrammarEvaluationViewModel()
    var interpretationViewModel = InterpretationEvaluationViewModel()
    
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
        guard chatHistory.count >= 2 else { return story.initialPrompt }
        let AImessage = chatHistory[chatHistory.count - 2]
        return !AImessage.isSent ? AImessage.text : nil
    }
    
    var lastUserAnswer: String? {
        guard let lastMessage = chatHistory.last else { return nil }
        return lastMessage.isSent ? lastMessage.text : nil
    }
    
    init(story: StoryDetail) {
        self.story = story
        self.timeDisplay = formatTime(maxRecordTime)
        
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
        
        resetTimerDisplay()
    }
    
    func sendMessage() {
        let messageText = transcriptDraft
        guard !messageText.isEmpty else { return }
        
        print("--- MESSAGE SENT ---")
        
        chatHistory.append(ChatMessage(text: messageText, isSent: true))
        interpretationViewModel.appendAnswer(messageText)
        cancelDraft()
        
        // Capture the prompts *before* starting async tasks
        guard let currentAIQuestion = self.lastAIQuestion,
              let currentUserAnswer = self.lastUserAnswer else {
            print("⚠️ Could not get grammar evaluation pair. This might be the first message.")
            
            // Still generate the AI follow-up
            isWaitingForAIResponse = true
            Task {
                print("--- AI PROCESS NEXT FOLLOW UP QUESTION (Mic Disabled) ---")
                await generateFollowUpQuestion()
            }
            return
        }

        // Launch the grammar evaluation asynchronously in the background
        Task {
            await evaluateGrammar(for: currentUserAnswer, prompt: currentAIQuestion)
        }
        
        // Launch the AI follow-up question
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
    private func evaluateGrammar(for text: String, prompt: String) async {
        print("--- STARTING GRAMMAR EVALUATION for: \(text) ---")
        
        // Add a placeholder card so the UI can show a loading state
        var loadingDetail = GrammarEvaluationDetail(
            promptText: prompt,
            originalText: text,
            correctedText: "",
            errors: [:],
            isLoading: true // Set loading flag
        )
        let loadingIndex = self.grammarViewModel.evaluationDetails.count
        self.grammarViewModel.evaluationDetails.append(loadingDetail)
        
        do {
            // Use the singleton GrammarAnalyst to generate the evaluation
            let newDetail = try await GrammarAnalyst.shared.generateEvaluation(
                for: text,
                speechPrompt: prompt
            )
            
            // Update the placeholder with the finished detail
            self.grammarViewModel.evaluationDetails[loadingIndex] = newDetail
            print("--- GRAMMAR EVALUATION FINISHED ---")
            
        } catch {
            print("❌ ERROR during grammar evaluation: \(error.localizedDescription)")
            // Update the placeholder to show an error
            loadingDetail.correctedText = "Evaluation failed: \(error.localizedDescription)"
            loadingDetail.isLoading = false
            self.grammarViewModel.evaluationDetails[loadingIndex] = loadingDetail
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
