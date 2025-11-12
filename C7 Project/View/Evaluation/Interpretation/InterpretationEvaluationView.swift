//
//  InterpretationEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct InterpretationEvaluationView: View {
    
    @StateObject var viewModel: InterpretationEvaluationViewModel
    
    init(viewModel: InterpretationEvaluationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(viewModel.items) { item in
                    InterpretationItemCard(
                        promptText: item.getPrompt(),
                        spokenText: item.getResponse(),
                        interpretedText: item.interpretedText
                    )
                    
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
//        .task {
//            // empty task for actual running
//            viewModel.appendPrompt("Pitch your skills to the HR before the elevator reaches the ground floor!")
//            viewModel.appendAnswer("I'm a self-described, born entrepreneur, from an early age I've always been eager to run a business.")
//            
//        }
    }

}

#Preview {
    InterpretationEvaluationView(viewModel: InterpretationEvaluationViewModel())
}
