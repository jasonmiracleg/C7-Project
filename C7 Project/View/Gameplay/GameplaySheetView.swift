//
//  GameplaySheetView.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 30/10/25.
//


import SwiftUI
import FoundationModels

struct GameplaySheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel: GameplayViewModel
    
    let story: StoryDetail
    
    init(story: StoryDetail) {
        self.story = story
        _viewModel = State(initialValue: GameplayViewModel(story: story))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: VerticalAlignment.center) {
                        HStack(alignment: VerticalAlignment.center) {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(viewModel.isTimeRunningOut ? .red : Color(.black.opacity(0.8)))
                                .font(.body)
                            Text(viewModel.timeDisplay)
                                .foregroundStyle(viewModel.isTimeRunningOut ? .red : .primary)
                                .fontWeight(viewModel.isTimeRunningOut ? .bold : .regular)
                        }
                        .animation(.easeInOut, value: viewModel.isTimeRunningOut)
                        
                        Spacer()
                        Text("Gameplay")
                            .font(.title2)
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
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ForEach(viewModel.chatHistory) { message in
                            MessageBubble(
                                text: message.text,
                                isSent: message.isSent
                            )
                        }
                        
                        if viewModel.isRecording {
                            HStack {
                                Spacer()
                                
                                RecordingIndicator()
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .background(Color.blue)
                                    .clipShape(.rect(
                                        topLeadingRadius: 16,
                                        bottomLeadingRadius: 16,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 16
                                    ))
                            }
                            .padding(.horizontal, 10)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                }
                .padding(.top, 12)
                .frame(height: 500)
                
                Spacer()
                
                if viewModel.isFinished {
                    Text("Good Job!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Now, Let's review how you did")
                        .padding(.bottom, 12)
                    NavigationLink(
                        destination: EvaluationView(
                            grammarViewModel: viewModel.grammarViewModel,
                            interpretationViewModel: viewModel.interpretationViewModel
                        )
                    ) {
                        Text("View Evaluation")
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color.accentColor.opacity(0.8))
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                } else {
                    
                    // Show model loading state
                    if viewModel.isModelLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading speech model...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                    } else if let error = viewModel.modelLoadError {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.red)
                            Text("Model Load Error")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                    } else if viewModel.isDraftMode {
                        HStack {
                            Button(action: {
                                viewModel.cancelDraft()
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color(.black))
                                    .padding(12)
                                    .background(
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                    )
                            }
                            
                            ZStack(alignment: .trailing) {
                                Text(viewModel.transcriptDraft)
                                    .frame(maxWidth: .infinity, minHeight:30, alignment: .leading)
                                    .padding(.vertical, 16)
                                    .padding(.leading, 20)
                                    .padding (.trailing, 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                
                                Button(action: {
                                    viewModel.sendMessage()
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.white)
                                        .padding(12)
                                        .background(
                                            Circle()
                                                .fill(Color.interactive)
                                        )
                                        .padding(.vertical, 24)
                                        .padding(.trailing, 16)
                                }
                            }
                        }
                        Spacer()
                        
                    } else if viewModel.isRecording {
                        Image("Sound Wave")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.stopRecording()
                        }) {
                            Image(systemName: "square.fill")
                                .foregroundStyle(Color(.white))
                                .font(Font.system(size: 32))
                                .padding(18)
                                .background(
                                    Circle()
                                        .fill(viewModel.canStopRecording ? Color.interactive : Color.gray.opacity(0.5))
                                )
                        }
                        .disabled(!viewModel.canStopRecording)
                        
                    } else {
                        
                        let isMicDisabled = !viewModel.permissionsGranted || viewModel.isWaitingForAIResponse || viewModel.isModelLoading
                        
                        Button(action: {
                            viewModel.startRecording()
                        }) {
                            Image(systemName: "microphone.fill")
                                .foregroundStyle(Color(.white))
                                .font(Font.system(size: 32))
                                .padding(18)
                                .background(
                                    Circle()
                                        .fill(isMicDisabled ? Color.gray.opacity(0.5) : Color.interactive)
                                )
                        }
                        .disabled(isMicDisabled)
                    }
                }
            }
            .padding(.horizontal, 24)
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}

// Preview
#Preview {
    GameplaySheetView(
        story: StoryDetail(
            mainTopic: "Pitching a new project",
            storyContext: "Ini adalah konteks cerita...",
            initialPrompt: "Ini adalah pertanyaan pertama untuk preview."
        )
    )
}
