//
//  PromptAndAnswer.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 10/11/25.
//
import Foundation

struct PromptResponse: Identifiable, Equatable{
    let id = UUID()
    let promptText: String
    let answerText: String
}
