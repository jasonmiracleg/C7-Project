//
//  GrammarItemCard.swift
//  C7 Project
//
//  Created by [Your Name] on 10/11/25.
//

import SwiftUI

struct GrammarItemCard: View {
    let detail: GrammarEvaluationDetail
    
    @Binding var selectedDetail: GrammarEvaluationDetail?
    @Binding var selectedSentenceIndex: Int?
    @Binding var isShowingPopup: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(detail.promptText)
                .font(.headline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            if !detail.isLoading && detail.totalErrorCount == 0 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.green)
                    Text("Great job! No errors found.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
            
            Divider()
            
            if detail.isLoading {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Evaluating grammar...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            
            } else {
                Text(buildAttributedText())
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .environment(\.openURL, OpenURLAction { url in
                        if let indexStr = url.host, let index = Int(indexStr) {
                            // ... (openURL action)
                            selectedDetail = detail
                            selectedSentenceIndex = index
                            isShowingPopup = true
                            return .handled
                        }
                        return .discarded
                    })
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func buildAttributedText() -> AttributedString {
        var attributedString = AttributedString()
        var sentenceIndex = 0
        
        // 1. ADD THIS: This counter tracks only the sentences with errors.
        var erroneousSentenceCounter = 0
        
        detail.originalText.enumerateSubstrings(in: detail.originalText.startIndex..<detail.originalText.endIndex, options: .bySentences) { (substring, substringRange, _, _) in
            if let sentence = substring {
                var attributedSentence = AttributedString(sentence)
                
                if !detail.errors(in: substringRange).isEmpty {
                    erroneousSentenceCounter += 1
                    
                    var container = AttributeContainer()
                    container.foregroundColor = .orange
                    container.underlineStyle = Text.LineStyle(pattern: .solid, color: .orange)
                    
                    container.link = URL(string: "sentence://\(sentenceIndex)")
                    attributedSentence.mergeAttributes(container)
                    
                    attributedString.append(attributedSentence)
                    
                    var indexString = AttributedString("[\(erroneousSentenceCounter)] ")
                    indexString.font = .caption2
                    indexString.baselineOffset = 10  // Add whitespace after superscript
                    indexString.foregroundColor = .orange
                    
                    attributedString.append(indexString)
                } else {
                    attributedString.append(attributedSentence)
                }
            }
            sentenceIndex += 1
        }
        
        return attributedString
    }
}

#Preview {
    // Create some sample data for the preview
    
    // 1. A detail object for the LOADING state
    let loadingDetail = GrammarEvaluationDetail(
        promptText: "Tell me about your weekend.",
        originalText: "I visit a cafe new last weekend...",
        correctedText: "",
        errors: [:],
        isLoading: true
    )
    
    // 2. A detail object for the NO ERRORS state
    let noErrorDetail = GrammarEvaluationDetail(
        promptText: "What are your career goals?",
        originalText: "I want to become a software engineer at a large tech company.",
        correctedText: "I want to become a software engineer at a large tech company.",
        errors: [:],
        isLoading: false
    )
    
    // 3. A detail object for the WITH ERRORS state
    let errorDetail = GrammarEvaluationDetail(
        promptText: "What was the last thing you read?",
        originalText: "I read interesting article today. It say that many young person...",
        correctedText: "I read an interesting article today. It said that many young people...",
        errors: [
            .ArticleOmission: [
                GrammarError(
                    type: "Article",
                    fullErrantType: "Article Omission",
                    originalText: "",
                    originalStartChar: 7,
                    originalEndChar: 7,
                    correctedText: "an",
                    correctedStartChar: 7,
                    correctedEndChar: 9
                )
            ],
            .VerbTenses: [
                GrammarError(
                    type: "Verb",
                    fullErrantType: "Verb Tense",
                    originalText: "say",
                    originalStartChar: 34,
                    originalEndChar: 37,
                    correctedText: "said",
                    correctedStartChar: 35,
                    correctedEndChar: 39
                )
            ]
        ],
        isLoading: false
    )

    // Render the different card states in a ScrollView
    ScrollView {
        VStack(spacing: 20) {
            Text("Card States").font(.largeTitle).padding(.bottom, 20)
            
            // --- Loading State ---
            Text("Loading State").font(.headline)
            GrammarItemCard(
                detail: loadingDetail,
                selectedDetail: .constant(nil),
                selectedSentenceIndex: .constant(nil),
                isShowingPopup: .constant(false)
            )
            
            // --- No Errors State ---
            Text("No Errors State").font(.headline)
            GrammarItemCard(
                detail: noErrorDetail,
                selectedDetail: .constant(nil),
                selectedSentenceIndex: .constant(nil),
                isShowingPopup: .constant(false)
            )
            
            // --- With Errors State ---
            Text("With Errors State").font(.headline)
            GrammarItemCard(
                detail: errorDetail,
                selectedDetail: .constant(nil),
                selectedSentenceIndex: .constant(nil),
                isShowingPopup: .constant(false)
            )
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
