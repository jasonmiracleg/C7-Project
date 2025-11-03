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
                        Text("On-Device Grammar Check")
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
                                await viewModel.runGrammarCheck()
                            }
                        }) {
                            HStack {
                                Text("1. Correct Grammar")
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
                        
                        if !viewModel.correctedText.isEmpty {
                            Text("Corrected Text:")
                                .font(.headline)
                            
                            Text(viewModel.correctedText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(8)
                                .textSelection(.enabled)
                            
                            // --- NEW: Flag Errors Button ---
                            Button(action: {
                                Task {
                                    await viewModel.runFlagErrors()
                                }
                            }) {
                                HStack {
                                    Text("2. Flag Errors (API Call)")
                                    if viewModel.isFlagging {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(viewModel.isFlagging || viewModel.isCheckingGrammar ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(viewModel.isFlagging || viewModel.isCheckingGrammar)
                        }
                        
                        // --- NEW: Flagging Response ---
                        if !viewModel.flaggingResponse.isEmpty {
                            Text("Flagging JSON Response:")
                                .font(.headline)
                            
                            ScrollView(.vertical, showsIndicators: true) {
                                Text(viewModel.flaggingResponse)
                                    .font(.system(.caption, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(8)
                                    .textSelection(.enabled)
                            }
                            .frame(height: 200)
                        }
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    // --- Section 2: API Server Health Check ---
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
