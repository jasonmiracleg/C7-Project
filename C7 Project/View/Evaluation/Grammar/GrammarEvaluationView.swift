//
//  GrammarEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct GrammarEvaluationView: View {
    
    @State private var viewModel = GrammarEvaluationViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EvaluationHeaderCard(
                    title: "Incorrect Grammar",
                    subtitle: "\(viewModel.incorrectSentences)/\(viewModel.totalSentences) sentences",
                    color: .orange
                )
                
                ForEach(viewModel.evaluationDetails) { detail in
                    GrammarItemCard(
                        detail: detail,
                        selectedDetail: $viewModel.selectedDetail,
                        selectedSentenceIndex: $viewModel.selectedSentenceIndex,
                        isShowingPopup: $viewModel.isShowingDetailPopup
                    )
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(isPresented: $viewModel.isShowingDetailPopup) {
            if let detail = viewModel.selectedDetail,
               let index = viewModel.selectedSentenceIndex {
                // Pass the full detail and index
                GrammarEvaluationModal(detail: detail, sentenceIndex: index)
                    .presentationDetents([.medium, .large])
            }
        }
        .task {
            await viewModel.loadData()  // DEBUG: Remove during integration with gameplay loop
        }
    }
}

#Preview {
    GrammarEvaluationView()
}
