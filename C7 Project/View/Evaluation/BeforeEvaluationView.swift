//
//  BeforeEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct BeforeEvaluationView: View {
    @StateObject private var dummyInterpretationVM = InterpretationEvaluationViewModel()
    
    var body: some View {
            NavigationStack {
                VStack {
                    NavigationLink("Go to Evaluation Page") {
                        EvaluationView(interpretationViewModel: dummyInterpretationVM)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationTitle("Home")
            }
            .onAppear{
                dummyInterpretationVM.appendPrompt("Hello there, this is a prompt")
                dummyInterpretationVM.appendAnswer("So this is an answer to the prompt. I am going to do some demo dummy filling this part in with some lengthy text so that the model can summarize this somehow.")
            }
        }
}

#Preview {
    BeforeEvaluationView()
}
