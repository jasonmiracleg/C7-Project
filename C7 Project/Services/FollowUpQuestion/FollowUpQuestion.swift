//
//  FollowUpQuestion.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 05/11/25.
//

import Foundation
import NaturalLanguage
import FoundationModels
import Playgrounds

@Generable()
struct FollowUpQuestionText {
    @Guide(description: "The scenario context")
    let scenario: String
    
    @Guide(description: "The question that has been answered")
    let question: String
    
    @Guide(description: "The user's answer")
    let userAnswer: String
}

actor FollowUpQuestion {
    private let session: LanguageModelSession
    
    init() {
        // Initialize the model and session
        let model = SystemLanguageModel()
        
        self.session = LanguageModelSession(model:model, instructions: followUpQuestionModelInstructions)
    }
    
    func generateFollowUpQuestion(scenario: String, question: String, userAnswer: String) async throws -> FollowUpQuestionText {
        let prompt = followUpQuestionSystemPrompt(scenario: scenario, question: question, userAnswer: userAnswer)
        let response = try await session.respond(to: prompt, generating: FollowUpQuestionText.self)
        return response.content
    }
}
