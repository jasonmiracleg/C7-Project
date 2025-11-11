//
//  GrammarEvaluationDetail.swift
//  C7 Project
//
//  Created by Savio Enoson on 10/11/25.
//

import Foundation
import SwiftUI

struct GrammarEvaluationDetail: Identifiable, Equatable {
    let id = UUID()
    let promptText: String
    let originalText: String
    var correctedText: String
    var errors: [SyntacticErrorType: [GrammarError]]
    var isLoading: Bool = false
    
    // Helper to split original text into sentences
    var originalSentences: [String] {
        var results: [String] = []
        originalText.enumerateSubstrings(in: originalText.startIndex..<originalText.endIndex, options: .bySentences) { substring, _, _, _ in
            if let sentence = substring { results.append(sentence) }
        }
        return results
    }
    
    // Helper to split corrected text into sentences
    var correctedSentences: [String] {
        var results: [String] = []
        // Handle empty case safely
        guard !correctedText.isEmpty else { return [] }
        
        correctedText.enumerateSubstrings(in: correctedText.startIndex..<correctedText.endIndex, options: .bySentences) { substring, _, _, _ in
            if let sentence = substring { results.append(sentence) }
        }
        return results
    }
    
    func originalSentenceRange(at index: Int) -> Range<String.Index>? {
        findSentenceRange(in: originalText, at: index)
    }
    
    /// Finds the range of the Nth sentence in the corrected text.
    func correctedSentenceRange(at index: Int) -> Range<String.Index>? {
        findSentenceRange(in: correctedText, at: index)
    }
    
    private func findSentenceRange(in text: String, at targetIndex: Int) -> Range<String.Index>? {
        var currentIndex = 0
        var result: Range<String.Index>?
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { _, range, _, stop in
            if currentIndex == targetIndex {
                result = range
                stop = true
            }
            currentIndex += 1
        }
        return result
    }
    
    // Helper to find errors that occur within a given range of the original text
    func errors(in sentenceRange: Range<String.Index>) -> [SyntacticErrorType: [GrammarError]] {
        var errorsInSentence: [SyntacticErrorType: [GrammarError]] = [:]
        
        // Pre-calculate integer offsets for the sentence range once
        let sentenceStartOffset = originalText.distance(from: originalText.startIndex, to: sentenceRange.lowerBound)
        let sentenceEndOffset = originalText.distance(from: originalText.startIndex, to: sentenceRange.upperBound)
        
        for (type, errorList) in errors {
            let filteredErrors = errorList.filter { error in
                // ROBUST CHECK: Does the error's character range overlap with the sentence's character range?
                // Using simple integer comparison is fast and safe.
                // An error overlaps if it starts before the sentence ends AND ends after the sentence starts.
                return error.originalStartChar < sentenceEndOffset && error.originalEndChar > sentenceStartOffset
            }
            if !filteredErrors.isEmpty {
                errorsInSentence[type] = filteredErrors
            }
        }
        
        return errorsInSentence
    }
}

// (Keep your SyntacticErrorType extension here as it was)
extension SyntacticErrorType {
    var color: Color {
        switch self {
        // Using slightly darker/richer shades for better contrast on both light/dark modes
        case .VerbTenses: return Color(red: 0.8, green: 0.1, blue: 0.1)         // Darker Red
        case .SubjectVerbAgreement: return Color(red: 0.85, green: 0.45, blue: 0.0) // Darker Orange
        case .ArticleOmission: return Color(red: 0.0, green: 0.4, blue: 0.8)      // Darker Blue
        case .PluralNounSuffix: return Color(red: 0.6, green: 0.1, blue: 0.6)     // Darker Purple
        case .CopulaOmission: return Color(red: 0.85, green: 0.1, blue: 0.5)      // Darker Pink
        case .WordOrder: return Color(red: 0.8, green: 0.65, blue: 0.0)           // Gold (Darker Yellow) - vital for light mode
        case .WordFormation: return Color(red: 0.0, green: 0.6, blue: 0.2)        // Darker Green
        case .IncorrectPreposition: return Color(red: 0.0, green: 0.6, blue: 0.7) // Teal (Darker Cyan) - vital for light mode
        case .NounPossesiveError: return Color(red: 0.6, green: 0.4, blue: 0.2)   // Brown
        case .Unknown: return Color.gray
        }
    }
    
    var title: String {
        switch self {
        case .VerbTenses: return "Verb Tense"
        case .SubjectVerbAgreement: return "Subject-Verb Agreement"
        case .ArticleOmission: return "Article Omission"
        case .PluralNounSuffix: return "Plural Noun Suffix"
        case .CopulaOmission: return "Copula Omission"
        case .WordOrder: return "Word Order"
        case .WordFormation: return "Word Formation"
        case .IncorrectPreposition: return "Incorrect Preposition"
        case .NounPossesiveError: return "Noun Possessive Error"
        case .Unknown(let type): return "Other Error (\(type))"
        }
    }
}
