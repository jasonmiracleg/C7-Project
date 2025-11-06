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
struct InterpretedText {
    @Guide(description:"The original unedited version of the text")
    let original: String
    
    @Guide(description:"A one line summary of the text")
     let summary: String
    
    @Guide(description:"A list of what you've interpreted from the user")
    let points: [String]
}


actor Interpretor {
    private let session: LanguageModelSession
    
    init() {
        // Initialize the model and session
        let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
        self.session = LanguageModelSession(model: model, instructions: interpretationModelInstructions)
    }
    
    func interpret(_ text: String) async throws -> InterpretedText {
        let prompt = interpretSystemPrompt(forTask: text)
        let response = try await session.respond(
            to: prompt,
            generating: InterpretedText.self
        )
        return response.content
    }
    
}
