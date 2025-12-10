//
//  GrammarEvaluationModal.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 03/11/25.
//

import SwiftUI

struct GrammarEvaluationModal: View {
    let detail: GrammarEvaluationDetail
    let sentenceIndex: Int
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Computed Properties
    private var originalSentenceRange: Range<String.Index>? {
        detail.originalSentenceRange(at: sentenceIndex)
    }
    
    private var correctedSentenceRange: Range<String.Index>? {
        detail.correctedSentenceRange(at: sentenceIndex)
    }
    
    private var sentenceErrors: [SyntacticErrorType: [GrammarError]] {
        guard let range = originalSentenceRange else { return [:] }
        return detail.errors(in: range)
    }

    // MARK: - View Body
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    sentenceComparisonSection
                    
                    Divider()
                    
                    // New Correction List
                    correctionListSection
                }
                .padding()
            }
        }
    }
    
    // MARK: - Major Subviews
    private var header: some View {
        HStack {
            Spacer()
            Text("Error Details").font(.headline)
            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24))
                    .foregroundStyle(.primary)
                    .clipShape(Circle())
            }
            .buttonStyle(.glass)
        }
        .padding()
    }
    
    private var sentenceComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Original").font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
                Text(buildHighlightedOriginalSentence())
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Corrected").font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
                Text(buildHighlightedCorrectedSentence())
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            }
        }
    }
    
    private var correctionListSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading) {
                Text("Corrections")
                    .font(.headline)

                Text("Rationale and corrections for each error.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ForEach(Array(sentenceErrors.keys.sorted(by: { $0.title < $1.title })), id: \.self) { type in
                if let errors = sentenceErrors[type] {
                    ErrorTypeSection(type: type, errors: errors)
                }
            }
        }
    }
    
    // MARK: - Highlighting Logic (Unchanged)
    private func buildHighlightedOriginalSentence() -> AttributedString {
        guard let sentenceRange = originalSentenceRange else { return AttributedString("Error finding sentence") }
        let originalSentence = String(detail.originalText[sentenceRange])
        var attributedString = AttributedString(originalSentence)
        
        let sentenceStartOffset = detail.originalText.distance(from: detail.originalText.startIndex, to: sentenceRange.lowerBound)
        let sentenceEndOffset = sentenceStartOffset + originalSentence.count
        
        for (type, errors) in sentenceErrors {
            for error in errors {
                if error.originalEndChar > sentenceStartOffset && error.originalStartChar < sentenceEndOffset {
                    let relativeStart = max(0, error.originalStartChar - sentenceStartOffset)
                    let relativeEnd = min(originalSentence.count, error.originalEndChar - sentenceStartOffset)
                    
                    if relativeStart < relativeEnd {
                        let startIdx = originalSentence.index(originalSentence.startIndex, offsetBy: relativeStart)
                        let endIdx = originalSentence.index(originalSentence.startIndex, offsetBy: relativeEnd)
                        
                        guard let attrStart = AttributedString.Index(startIdx, within: attributedString),
                              let attrEnd = AttributedString.Index(endIdx, within: attributedString) else {
                            continue
                        }
                        let attrRange = attrStart..<attrEnd
                        
                        attributedString[attrRange].font = .body.italic()
                        attributedString[attrRange].backgroundColor = type.color.opacity(0.25)
                        attributedString[attrRange].underlineStyle = Text.LineStyle(pattern: .solid, color: type.color)
                    }
                }
            }
        }
        return attributedString
    }
    
    private func buildHighlightedCorrectedSentence() -> AttributedString {
        guard let sentenceRange = correctedSentenceRange else { return AttributedString("Sentence not available") }
        let correctedSentence = String(detail.correctedText[sentenceRange])
        var attributedString = AttributedString(correctedSentence)

        let sentenceStartOffset = detail.correctedText.distance(from: detail.correctedText.startIndex, to: sentenceRange.lowerBound)
        let sentenceEndOffset = sentenceStartOffset + correctedSentence.count
        
        for (type, errors) in sentenceErrors {
            for error in errors {
                if error.correctedEndChar > sentenceStartOffset && error.correctedStartChar < sentenceEndOffset {
                    let relativeStart = max(0, error.correctedStartChar - sentenceStartOffset)
                    let relativeEnd = min(correctedSentence.count, error.correctedEndChar - sentenceStartOffset)
                    
                    if relativeStart < relativeEnd {
                        let startIdx = correctedSentence.index(correctedSentence.startIndex, offsetBy: relativeStart)
                        let endIdx = correctedSentence.index(correctedSentence.startIndex, offsetBy: relativeEnd)
                        
                        guard let attrStart = AttributedString.Index(startIdx, within: attributedString),
                              let attrEnd = AttributedString.Index(endIdx, within: attributedString) else {
                            continue
                        }
                        let attrRange = attrStart..<attrEnd
                        
                        // Apply styles
                        attributedString[attrRange].font = .body.italic()
                        attributedString[attrRange].backgroundColor = type.color.opacity(0.15)
                        attributedString[attrRange].underlineStyle = Text.LineStyle(pattern: .solid, color: type.color)
                    }
                }
            }
        }
        return attributedString
    }
}

// MARK: - New Helper Views

struct ErrorTypeSection: View {
    let type: SyntacticErrorType
    let errors: [GrammarError]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header for the Error Type
//            Text(type.title)
//                .font(.headline)
//                .foregroundStyle(type.color)
//            
//            Text(type.shortDescription)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
            
            // List of Correction Cards for this type
            ForEach(errors) { error in
                CorrectionCard(error: error, type: type)
            }
        }
    }
}

struct CorrectionCard: View {
    let error: GrammarError
    let type: SyntacticErrorType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Original -> Correction Row
            HStack(alignment: .center, spacing: 8) {
                Text(error.originalText.isEmpty ? "[-]" : error.originalText)
                    .font(.system(.body, design: .monospaced)) // Monospace for code-like clarity
                    .padding(6)
                    .background(.secondary.opacity(0.1))
                    .cornerRadius(6)
                    .strikethrough()
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(error.correctedText)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .padding(6)
                    .background(type.color.opacity(0.35))
                    .cornerRadius(6)
            }
            
            // Rationale text below
            Text(error.correctionRationale)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    let sampleDetail = GrammarEvaluationDetail(
        promptText: "Sample",
        originalText: "I visit a cafe new last weekend.",
        correctedText: "I visited a new cafe last weekend.",
        errors: [
            .VerbTenses: [
                GrammarError(type: "VERB:TENSE", fullErrantType: "R:VERB:TENSE", originalText: "visit", originalStartChar: 2, originalEndChar: 7, correctedText: "visited", correctedStartChar: 2, correctedEndChar: 9, correctionRationale: "Use past tense 'visited' because it happened in the past.")
            ],
            .WordOrder: [
                GrammarError(type: "WO", fullErrantType: "R:WO", originalText: "cafe new", originalStartChar: 10, originalEndChar: 18, correctedText: "new cafe", correctedStartChar: 12, correctedEndChar: 20, correctionRationale: "Adjectives come before nouns in English.")
            ]
        ]
    )
    
    return GrammarEvaluationModal(detail: sampleDetail, sentenceIndex: 0)
}
