//
//  FineTuningView.swift
//  C7 Project
//
//  Created by Savio Enoson on 07/11/25.
//

import SwiftUI
import Foundation


struct FineTuningView: View {
    
    // The paragraph to be analyzed, from your playground
    private let paragraph = """
    I'm trying to find the best way to give my new coworker feedback. He's a very nice person, but he's also a very sensible person who gets upset easily, especially if you criticize his code. It's a bit strange, because in other ways he seems very practical. I just want to find a good way to work with him.
    """
    
    // State variables to hold the results
    @State private var correctedText: String = ""
    @State private var errorFlagDescriptions: [String] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if isLoading {
                        ProgressView("Analyzing Text...")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let errorMessage = errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.body)
                        }
                    } else {
                        // Display the original paragraph
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Original Paragraph")
                                .font(.headline)
                            Text(paragraph)
                                .font(.body.monospaced())
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                        
                        Divider()
                        
                        // Display the corrected text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Corrected Text")
                                .font(.headline)
                            Text(correctedText.isEmpty ? "No corrections made." : correctedText)
                                .font(.body)
                        }
                        
                        Divider()
                        
                        // Display the error flags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Error Flags")
                                .font(.headline)
                            
                            if errorFlagDescriptions.isEmpty {
                                Text("No flags generated.")
                                    .foregroundColor(.secondary)
                            } else {
                                // Loop over the flag descriptions
                                ForEach(errorFlagDescriptions, id: \.self) { flagDesc in
                                    Text(flagDesc)
                                        .font(.system(size: 12, design: .monospaced))
                                        .padding(8)
                                        .background(Color(.tertiarySystemBackground))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Fine Tuning Analysis")
            .task {
                // Runs the analysis when the view first appears
                await performAnalysis()
            }
        }
    }
    
    /// Performs the grammar analysis from the playground.
    private func performAnalysis() async {
        isLoading = true
        errorMessage = nil
        
        let analyst = GrammarAnalyst()
        
        do {
            let (corrected, flags) = try await analyst.runAnalysisForTuning(
                on: paragraph,
                category: .Misselection,
                doValidation: true
            )
            
            // Update the state on the main thread
            await MainActor.run {
                self.correctedText = corrected
                // Store the string description of each flag
                self.errorFlagDescriptions = flags.map { String(describing: $0) }
                self.isLoading = false
            }
            
        } catch {
            // Handle any errors
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

#Preview {
    FineTuningView()
}
