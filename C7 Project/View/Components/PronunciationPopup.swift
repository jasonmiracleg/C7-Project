//
//  PronunciationPopup.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 31/10/25.
//
import SwiftUI

struct PronunciationPopup: View {
    @Binding var correctionText: String
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack {
                Text("Entrepreneur")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.glass)
            }
            .padding(.top, 16)
            VStack(spacing: 8) {
                HStack(spacing: 14) {
                    Text("Your Answer")
                        .font(.title3.weight(.medium))
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Text(":")

                    Image(systemName: "waveform")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Button(action: {
                        // play sound
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                Divider()
                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading) {
                        Text("The Correct Pronunciation")
                            .font(.title3.weight(.medium))
                        Text(correctionText)
                            .font(.callout)
                    }
                    Spacer()
                    Text(":")

                    Image(systemName: "waveform")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Button(action: {
                        // play sound
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
    }
}
