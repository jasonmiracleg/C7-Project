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
                            // SUPER SIMPLE NOW: just set the state
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
        
        detail.originalText.enumerateSubstrings(in: detail.originalText.startIndex..<detail.originalText.endIndex, options: .bySentences) { (substring, substringRange, _, _) in
            if let sentence = substring {
                var attributedSentence = AttributedString(sentence)
                
                if !detail.errors(in: substringRange).isEmpty {
                    var container = AttributeContainer()
                    container.foregroundColor = .orange
                    container.underlineStyle = Text.LineStyle(pattern: .solid, color: .orange)
                    container.link = URL(string: "sentence://\(sentenceIndex)")
                    attributedSentence.mergeAttributes(container)
                    
                    // Add sentence to main string
                    attributedString.append(attributedSentence)
                    
                    // Add superscript for sentence index i.e. [1], [2], ...
                    var indexString = AttributedString("[\(sentenceIndex + 1)] ")
                    indexString.font = .caption2
                    indexString.baselineOffset = 10  // Add whitespace after superscript
                    indexString.foregroundColor = .orange
                    
                    attributedString.append(indexString)
                    // ---------------------------------------------------------------
                } else {
                    // Just append the normal sentence without highlight or index
                    attributedString.append(attributedSentence)
                }
            }
            sentenceIndex += 1
        }
        
        return attributedString
    }
}
