//
//  EvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

enum tabSegments: String, CaseIterable{
    case pronunciation = "Pronunciation"
    case grammar = "Grammar"
    case interpretation = "Interpretation"
}

struct EvaluationView: View {
    @State private var selectedSegment: tabSegments = .pronunciation
    
    @State private var showingPronunciationPopup = false
    @State private var pronunciationCorrection = ""
    
    
    @State private var showingGrammarPopup = false
    @State private var selectedGrammarDetail: GrammarEvaluationDetail? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Evaluation Tab", selection: $selectedSegment){
                ForEach(tabSegments.allCases, id: \.self){
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            chosenTabView(
                selectedTab: selectedSegment,
                showingPronunciationPopup: $showingPronunciationPopup,
                pronunciationCorrection: $pronunciationCorrection,
                showingGrammarPopup: $showingGrammarPopup,
                selectedGrammarDetail: $selectedGrammarDetail
            )
            
            Spacer()
            
        }
        .navigationTitle("Evaluation")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            Group {
                if showingPronunciationPopup || showingGrammarPopup {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingPronunciationPopup = false
                            showingGrammarPopup = false
                        }
                }
                
                if showingPronunciationPopup {
                    PronunciationPopup(
                        correctionText: pronunciationCorrection,
                        isPresented: $showingPronunciationPopup
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                if showingGrammarPopup, let detail = selectedGrammarDetail {
                    GrammarPopup(
                        detail: detail,
                        isPresented: $showingGrammarPopup
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: showingPronunciationPopup || showingGrammarPopup)
        )
    }
}

struct chosenTabView: View {
    var selectedTab: tabSegments
    
    @Binding var showingPronunciationPopup: Bool
    @Binding var pronunciationCorrection: String
    @Binding var showingGrammarPopup: Bool
    @Binding var selectedGrammarDetail: GrammarEvaluationDetail?
    
    var body: some View {
        switch selectedTab {
            case .pronunciation:
                PronunciationEvaluationView(showingPronunciationPopup: $showingPronunciationPopup, pronunciationCorrection: $pronunciationCorrection)
            case .grammar:
                GrammarEvaluationView(
                    showingPopup: $showingGrammarPopup,
                    selectedGrammarDetail: $selectedGrammarDetail
                )
            case .interpretation:
                InterpretationEvaluationView()
        }
    }
}

#Preview {
    EvaluationView()
}
