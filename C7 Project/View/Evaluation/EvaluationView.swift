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
    
    var body: some View {
        VStack {
            Picker("Evaluation Tab", selection: $selectedSegment){
                ForEach(tabSegments.allCases, id: \.self){
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            chosenTabView(selectedTab: selectedSegment)
            Spacer()
            
        }
        .navigationTitle("Evaluation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct chosenTabView: View {
    var selectedTab: tabSegments
    
    var body: some View {
        switch selectedTab {
            case .pronunciation:
                PronunciationEvaluationView()
            case .grammar:
                GrammarEvaluationView()
            case .interpretation:
                InterpretationEvaluationView()
        }
    }
}

#Preview {
    EvaluationView()
}
