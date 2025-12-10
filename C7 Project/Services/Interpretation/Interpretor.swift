//
//  Interpretor.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 04/11/25.
//

import Foundation
import NaturalLanguage
import FoundationModels
import Playgrounds


@Generable
struct InterpretedText: Equatable {
    @Guide(description:"The original unedited version of the text")
    let original: String
    
    @Guide(description:"A one line summary of the text")
    let summary: String
    
    @Guide(description:"A list of what you've interpreted from the user")
    let points: [String]
}


class Interpretor {
    static let shared = Interpretor()
    private var session: LanguageModelSession
    
    private init() {
        self.session = Self.createNewSession()
    }
    
    private static func createNewSession() -> LanguageModelSession {
        let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
        return LanguageModelSession(model: model, instructions: interpretationModelInstructions)
    }
    
    func interpret(_ text: String) async throws -> InterpretedText {
        while session.isResponding {
            try await Task.sleep(for: .milliseconds(100))
        }
        
        // Debug: refresh session every time
        self.session = Self.createNewSession()
        let prompt = interpretSystemPrompt(forTask: text)
        
        do {
            let response = try await session.respond(
                to: prompt,
                generating: InterpretedText.self
            )
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            print("Warning: Exceeded context window size. Context: \(context).")
            print("Re-initializing interpretation session and retrying...")

            // Re-initialize the session
            self.session = Self.createNewSession()
            
            // Retry the request once
            let response = try await session.respond(
                to: prompt,
                generating: InterpretedText.self
            )
            return response.content
        } catch {
            // Handle all other potential errors
            print("An unexpected error occurred during interpretation: \(error)")
            throw error
        }
    }
    
}
