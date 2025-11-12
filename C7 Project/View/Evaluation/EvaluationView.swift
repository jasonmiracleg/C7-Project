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
    
    @StateObject var interpretationViewModel: InterpretationEvaluationViewModel
    
    @State private var showingPronunciationPopup = false
    @State private var pronunciationCorrection = ""
    
    // View Models
    let grammarViewModel: GrammarEvaluationViewModel
    let interpretationViewModel: InterpretationEvaluationViewModel
    
    
    
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
                grammarViewModel: grammarViewModel,
                interpretationViewModel: interpretationViewModel
            )
            
            Spacer()
            
        }
        .navigationTitle("Evaluation")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPronunciationPopup) {
            PronunciationPopup(
                correctionText: $pronunciationCorrection,
                isPresented: $showingPronunciationPopup
            )
            .presentationDetents([.medium])
        }
    }
}

struct chosenTabView: View {
    var selectedTab: tabSegments
    
    @Binding var showingPronunciationPopup: Bool
    @Binding var pronunciationCorrection: String
    
    // View Models
    let grammarViewModel: GrammarEvaluationViewModel
    let interpretationViewModel: InterpretationEvaluationViewModel
    
    var body: some View {
        switch selectedTab {
            case .pronunciation:
                PronunciationEvaluationView(showingPronunciationPopup: $showingPronunciationPopup, pronunciationCorrection: $pronunciationCorrection)
            case .grammar:
                GrammarEvaluationView(viewModel: grammarViewModel)
            case .interpretation:
                InterpretationEvaluationView(viewModel: interpretationViewModel)
        }
    }
}

#Preview {
    EvaluationView(
        grammarViewModel: GrammarEvaluationViewModel(),
        interpretationViewModel: InterpretationEvaluationViewModel() // 5. UPDATE PREVIEW
    )
}
