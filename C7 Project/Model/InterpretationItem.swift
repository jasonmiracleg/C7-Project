//
//  InterpretationItem.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 05/11/25.
//

import Foundation

// MARK: - Local Model
struct InterpretationItem: Identifiable, Equatable {
    let id = UUID()
    let promptResponse: PromptResponse
    var interpretedText: InterpretedText? = nil
    
    mutating func addInterpretation(_ interpretation: InterpretedText){
        interpretedText = interpretation
    }
    
    func getPrompt() -> String {
        return promptResponse.promptText
    }
    
    func getResponse() -> String {
        return promptResponse.answerText
    }
}
