//
//  InterpretPlayground.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 04/11/25.
//
import FoundationModels
import Playgrounds

#Playground {
    let instructs = interpretationModelInstructions
    
    let testText = """
    I’m a self-described, born entrepreneur, from an early age I’ve always been eager to run a business.
    """
    
    let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)    
    // Create a new session with the language model.
    let session = LanguageModelSession(model: model, instructions: instructs)

    // Asynchronously generate a response from a text prompt.
    let response = try await session.respond(to: """
        Your task is to summarize what the user said into concise bullet points. Nothing more than the bullet points and no information left; share all the information that you received from the user in the specific text.
        
        TEXT:
        "\(testText)"
        """,
                                             generating: InterpretedText.self
    )
}
