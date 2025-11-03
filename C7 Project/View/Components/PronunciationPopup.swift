//
//  PronunciationPopup.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 31/10/25.
//
import SwiftUI

struct PronunciationPopup: View {
    let correctionText: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("The correct pronunciation would be:")
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
                Text(correctionText)
                    .font(.title3.weight(.medium))
                
                Spacer()
                
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Button(action: {
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
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
