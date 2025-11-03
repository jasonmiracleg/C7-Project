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
    @Binding var selectedGrammarDetail: GrammarEvaluationDetail?
    let grammarDetails: [String: GrammarEvaluationDetail]?
    
    // Initializer for Pronunciation
    init(
         promptText: String,
         spokenText: AttributedString,
         showingPronunciationPopup: Binding<Bool>,
         pronunciationCorrection: Binding<String>) {
        self.promptText = promptText
        self.spokenText = spokenText
        self._showingPronunciationPopup = showingPronunciationPopup
        self._pronunciationCorrection = pronunciationCorrection
        self._showingGrammarPopup = .constant(false)
        self._selectedGrammarDetail = .constant(nil)
        self.grammarDetails = nil
    }
    
    // Initializer for Grammar
    init(
         promptText: String,
         spokenText: AttributedString,
         showingGrammarPopup: Binding<Bool>,
         selectedGrammarDetail: Binding<GrammarEvaluationDetail?>,
         grammarDetails: [String: GrammarEvaluationDetail]) {
        self.promptText = promptText
        self.spokenText = spokenText
        self._showingPronunciationPopup = .constant(false)
        self._pronunciationCorrection = .constant("")
        self._showingGrammarPopup = showingGrammarPopup
        self._selectedGrammarDetail = selectedGrammarDetail
        self.grammarDetails = grammarDetails
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
                            // Handle Pronunciation
                            let correction = String(url.host ?? "error")
                            pronunciationCorrection = correction
                            showingPronunciationPopup = true
                            return .handled
                        } else if url.scheme == "grammar" {
                            // Handle Grammar
                            let key = String(url.host ?? "")
                            // Look up the detail object from the map
                            if let detail = grammarDetails?[key] {
                                selectedGrammarDetail = detail
                                showingGrammarPopup = true
                            }
                            return .handled
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

