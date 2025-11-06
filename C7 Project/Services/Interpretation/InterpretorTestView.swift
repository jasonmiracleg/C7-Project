//
//  InterpretorTestView.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 04/11/25.
//

import SwiftUI
import FoundationModels

struct InterpretorTestView: View {
    @State private var inputText = ""
    @State private var interpreted: InterpretedText?
    @State private var isLoading = false
    @State private var error: String?
    
    let interpretor = Interpretor()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 🧾 Input area
                TextEditor(text: $inputText)
                    .padding()
                    .frame(height: 120)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
                    .padding(.horizontal)

                // ▶️ Button
                Button(action: {
                    Task {
                        await runInterpretation()
                    }
                }) {
                    Text("Interpret Text")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                // 🌀 Loading indicator
                if isLoading {
                    ProgressView("Interpreting...")
                        .padding()
                }

                // ✅ Result
                if let result = interpreted {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💡 **Summary:** \(result.summary)")
                            Text("📋 **Points:**")
                            ForEach(result.points, id: \.self) { point in
                                Text("• \(point)")
                            }
                        }
                        .padding()
                    }
                }

                // ❌ Error message
                if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Text Interpreter")
        }
    }

    // MARK: - Logic
    private func runInterpretation() async {
        isLoading = true
        error = nil
        interpreted = nil

        do {
            let result = try await interpretor.interpret(inputText)
            interpreted = result
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    InterpretorTestView()
}
