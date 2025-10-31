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
    
    var body: some View {
        HStack(alignment: .center, spacing: 75) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(12)
    }
}

#Preview {
    EvaluationHeaderCard(
        title: "Incorrect Pronunciation",
        subtitle: "20/130 words"
    )
}
