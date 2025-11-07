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
    let promptText: String
    let spokenText: String
    var interpretedText: InterpretedText? = nil
    
    mutating func addInterpretation(_ interpretation: InterpretedText){
        interpretedText = interpretation
    }
}
