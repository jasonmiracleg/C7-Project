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
    
    var totalErrorCount: Int {
        errors.values.reduce(0) { $0 + $1.count }
    }
    
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
        // Safeguard against empty corrected text if analysis failed
        guard !correctedText.isEmpty else { return nil }
        return findSentenceRange(in: correctedText, at: index)
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
