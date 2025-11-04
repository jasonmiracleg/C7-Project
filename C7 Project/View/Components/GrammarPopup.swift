//
//  GrammarPopup.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 01/11/25.
//

import SwiftUI

struct GrammarPopup: View {
    let detail: GrammarEvaluationDetail
    @Binding var isPresented: Bool
    
    @State private var showingDetailModal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            
            HStack(spacing: 12) {
                Text("\"\(detail.correctedSentence)\"")
                    .font(.title3.weight(.regular))
                    .italic()
                
                Spacer()
                
                Button(action: {
                    showingDetailModal = true
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
        .fullScreenCover(isPresented: $showingDetailModal) {
            DetailEvaluationModal(
                detail: detail,
                isPresented: $showingDetailModal
            )
        }
    }
}
