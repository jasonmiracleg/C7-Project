//
//  GrammarPopup.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 01/11/25.
//

import SwiftUI

struct GrammarPopup: View {
    let correctionText: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 1. Header with Title and Close Button
            HStack {
                Text("The correct grammar would be:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            
            // 2. Grammar Correction and "See Details"
            HStack(spacing: 12) {
                Text(correctionText)
                    .font(.title3.weight(.medium))
                    .italic()
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("See Details")
                        .font(.headline)
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 30) 
    }
}
