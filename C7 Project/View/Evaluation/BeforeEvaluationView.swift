//
//  BeforeEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct BeforeEvaluationView: View {
    var body: some View {
            NavigationStack {
                VStack {
                    NavigationLink("Go to Evaluation Page") {
                        EvaluationView()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationTitle("Home")
            }
        }
}

#Preview {
    BeforeEvaluationView()
}
