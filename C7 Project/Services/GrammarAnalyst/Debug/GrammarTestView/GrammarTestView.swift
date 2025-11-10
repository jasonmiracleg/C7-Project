//
//  GrammarTestView.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import SwiftUI

struct GrammarTestView: View {
    
    @State private var viewModel = GrammarTestViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- Section 1: On-Device Grammar Check ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("On-Device Full Analysis")
                            .font(.title2.weight(.bold))
                        
                        Text("Input Text:")
                            .font(.headline)
                        
                        TextEditor(text: $viewModel.inputText)
                            .frame(height: 150)
                            .padding(4)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .font(.body)
                        
                        Button(action: {
                            Task {
                                await viewModel.runFullAnalysis()
                            }
                        }) {
                            HStack {
                                // Updated button text
                                Text("Run Full Analysis")
                                if viewModel.isCheckingGrammar {
                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(viewModel.isCheckingGrammar ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isCheckingGrammar)
                        
                        Text("Corrected Text:")
                            .font(.headline)
                        
                        Text(viewModel.correctedText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(8)
                            .textSelection(.enabled)
                        
                        // --- NEW: Validated Flags Output ---
                        Text("Validated Semantic Flags (\(viewModel.validatedFlags.count)):")
                            .font(.headline)
                            .padding(.top, 10)
                        
                        VStack(alignment: .leading) {
                            if viewModel.validatedFlags.isEmpty {
                                Text("No valid semantic flags found.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(viewModel.validatedFlags, id: \.self) { flag in
                                    Text(flag.description)
                                        .padding(.vertical, 5)
                                    Divider()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)
                        // --- End New Section ---
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    // --- Section 2: API Server Error Flagging ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("API Server Error Flagging")
                            .font(.title2.weight(.bold))
                        
                        // This button now works with the text generated above
                        Button(action: {
                            Task {
                                await viewModel.runApiFlagErrors()
                            }
                        }) {
                            HStack {
                                Text("Flag Errors (API)")
                                if viewModel.isFlaggingApi {
                                    ProgressView().tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(viewModel.isFlaggingApi ? Color.gray : Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isFlaggingApi || viewModel.isCheckingGrammar || viewModel.correctedText.isEmpty)
                        
                        Text("API Response:")
                            .font(.headline)
                        
                        Text(viewModel.flagApiResponse)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(8)
                            .textSelection(.enabled)
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    // --- Section 3: API Server Health Check ---
                    VStack(spacing: 10) {
                        Text("API Server Health Check")
                            .font(.title2.weight(.bold))
                        
                        Text(viewModel.serverStatus)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                        
                        Button("Run Health Check") {
                            Task {
                                await viewModel.checkServerHealth()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Debug Menu")
            .task {
                // Run the server health check once on appear
                await viewModel.checkServerHealth()
            }
        }
    }
}

#Preview {
    GrammarTestView()
}
