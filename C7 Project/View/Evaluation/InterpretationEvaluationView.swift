//
//  InterpretationEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct InterpretationEvaluationView: View {
    
    @StateObject private var viewModel = InterpretationEvaluationViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            // this block is for debugging the model, whether its actually interpreting or nah
            if let task = viewModel.currentTaskDescription {
                HStack {
                    ProgressView()
                    Text(task)
                        .font(.subheadline)
                }
                .padding()
            }
            //end here
            
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(viewModel.items) { item in
                    InterpretationItemCard(
                        promptText: item.promptText,
                        spokenText: item.spokenText,
                        interpretedText: item.interpretedText
                    )
                    
                    // debugging
                    Text(item.interpretedText == nil ? "oStill interpreting" : "✅ Interpreted")
                        .font(.caption)
                        .foregroundColor(item.interpretedText == nil ? .orange : .green)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .task {
            // remove this if you dont wanna use dummy data
            viewModel.loadDummyData()
            
            await viewModel.loadInterpretations()
        }
    }

}

#Preview {
    InterpretationEvaluationView()
}
