//
//  GrammarAnalyst.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import Foundation
import NaturalLanguage
import FoundationModels

// Generable template to normalize model responses
@Generable
struct TextBlock {
    @Guide(description: "Populate this field with the **original**, unedited input text.")
    let originalText: String
    
    @Guide(description: "Populate this field with the **corrected** version of the input text.")
    var correctedText: String = ""
}

actor GrammarAnalyst {
    
    private let session: LanguageModelSession
    
    init() {
        // Initialize the model and session
        let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
        self.session = LanguageModelSession(model: model, instructions: grammarCheckSystemPrompt)
    }
    
    /// Runs the single, concatenated check (all categories at once)
    func correctGrammar(text: String) async throws -> String {
        // Use the "checkAllCategories" prompt for a comprehensive check
        let prompt = checkAllCategories(forTask: text)
        let correctedText = try await checkGrammar(session: session, prompt: prompt)
        return correctedText
        
    // MARK: -- Test with direct String generation (for permsisive content)
    //    struct TempData: Decodable {
    //        let text: String
    //    }
    //
    //    var correctedText: String = ""
    //    if let jsonData = response.content.data(using: .utf8) {
    //        do {
    //            // 3. Create a decoder and decode the data
    //            let decoder = JSONDecoder()
    //            let decodedData = try decoder.decode(TempData.self, from: jsonData)
    //
    //            correctedText = decodedData.text
    //        } catch {
    //            print("Error decoding JSON: \(error)")
    //        }
    //    }
    //
    //    return correctedText
    }
    
    /// Runs several grammar check categories sequentially
    func correctGrammarSequentially(session: LanguageModelSession, text: String) async throws -> String {
        let checkFunctions: [(String) -> String] = [
            generalGrammarCheck,
            articlesCheck,
            copulaCheck,
            adjectiveOrderCheck,
            tensesCheck,
            pluralityCheck,
            modalityCheck
        ]
        
        // Original text
        var currentText = text
        
        // Check for each category in sequential order.
        for promptGenerator in checkFunctions {
            let prompt = promptGenerator(currentText)
            currentText = try await checkGrammar(session: session, prompt: prompt)
        }
        
        // Return the final text after all checks have run.
        return currentText
    }
    
    /// Checks for a specific type of grammatical error type
    private func checkGrammar(session: LanguageModelSession, prompt: String) async throws -> String {
        let response = try await session.respond(
            to: prompt,
            generating: TextBlock.self,
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        )
        
        return response.content.correctedText
    }
}
