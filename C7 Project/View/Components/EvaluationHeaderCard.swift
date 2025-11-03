//
//  EvaluationHeaderCard.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct EvaluationHeaderCard: View {
    let title: String
    let subtitle: String
    
    
    private var score: String {
        subtitle.components(separatedBy: " ").first ?? ""
    }
    
    private var scoreLabel: String {
        subtitle.components(separatedBy: " ").dropFirst().joined(separator: " ")
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.trailing, 100)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(score)
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text(scoreLabel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
    }
}
#Preview {
    EvaluationHeaderCard(
        title: "Incorrect Pronunciation",
        subtitle: "20/130 words"
    )
}
