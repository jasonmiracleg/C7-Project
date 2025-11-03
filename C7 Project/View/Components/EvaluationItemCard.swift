//
//  EvaluationItemCard.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct EvaluationItemCard: View {
    let promptText: String
    let spokenText: AttributedString
    
    @Binding var showingPronunciationPopup: Bool
    @Binding var pronunciationCorrection: String
    @Binding var showingGrammarPopup: Bool
    @Binding var grammarCorrection: String
    
    // Initializer for Pronunciation
    init(promptText: String,
         spokenText: AttributedString,
         showingPronunciationPopup: Binding<Bool>,
         pronunciationCorrection: Binding<String>) {
        self.promptText = promptText
        self.spokenText = spokenText
        self._showingPronunciationPopup = showingPronunciationPopup
        self._pronunciationCorrection = pronunciationCorrection
        self._showingGrammarPopup = .constant(false)
        self._grammarCorrection = .constant("")
    }
    
    // Initializer for Grammar
    init(promptText: String,
         spokenText: AttributedString,
         showingGrammarPopup: Binding<Bool>,
         grammarCorrection: Binding<String>) {
        self.promptText = promptText
        self.spokenText = spokenText
        self._showingPronunciationPopup = .constant(false)
        self._pronunciationCorrection = .constant("")
        self._showingGrammarPopup = showingGrammarPopup
        self._grammarCorrection = grammarCorrection
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(promptText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                
                Text(spokenText)
                    .font(.body)
                    .foregroundColor(Color(UIColor.label))
                    .fixedSize(horizontal: false, vertical: true)
                    .environment(\.openURL, OpenURLAction { url in
                        if url.scheme == "popup" {
                            let correction = String(url.host ?? "error")
                            pronunciationCorrection = correction
                            showingPronunciationPopup = true
                            return .handled
                        } else if url.scheme == "grammar" {
                            // Parse query item "text" using URLComponents
                            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                               let value = components.queryItems?.first(where: { $0.name == "text" })?.value,
                               !value.isEmpty {
                                grammarCorrection = value
                                showingGrammarPopup = true
                                return .handled
                            } else {
                                // Fallbacks for older links (host or lastPathComponent)
                                let hostOrPath = url.host ?? url.lastPathComponent
                                let decoded = hostOrPath.removingPercentEncoding ?? hostOrPath
                                if !decoded.isEmpty {
                                    grammarCorrection = decoded
                                    showingGrammarPopup = true
                                    return .handled
                                }
                            }
                            return .discarded
                        }
                        return .discarded
                    })
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}
