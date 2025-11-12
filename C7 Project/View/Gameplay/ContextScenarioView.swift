//
//  ContextScenarioView.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 30/10/25.
//

import SwiftUI

struct ContextScenarioView: View {
    let scenario: Scenario
    
    @StateObject private var viewModel = RandomScenarioViewModel()
    @State private var selectedStory: StoryDetail?
    @State private var showGameplaySheet = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack(alignment: VerticalAlignment.center) {
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
            .padding(.horizontal, 24)

            
            if let story = selectedStory {
                
                Text(story.mainTopic)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                VStack {
                    Spacer()

                    Text(story.storyContext)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                        )
                        .overlay(alignment: .bottom) {
                            Triangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width:30, height: 20)
                                .offset(x: 50, y: 20)
                        }
                    
                    Image("Context")
                        .resizable()
                        .frame(width: 350, height: 350)
//                        .background(.red)
                        .padding(.top, 12)
                    
                    Spacer()
                    
                    Button("START YOUR CONVERSATION") {
                        showGameplaySheet = true
                    }
                    .font(.headline)
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(Color.interactive)
                    )
                    .foregroundStyle(Color.white)
                }
                .padding(.horizontal, 24)
                
            } else {
                Spacer()
                ProgressView("Loading Story...")
                Spacer()
            }
        }
        .onAppear {
            if selectedStory == nil {
                self.selectedStory = viewModel.getRandomStory(for: scenario.title)
            }
        }
        .fullScreenCover(isPresented: $showGameplaySheet) {
            if let story = selectedStory {
                GameplaySheetView(story: story)
            }
        }
    }
}
#Preview {
    let sampleScenario = Scenario(
        title: "Presenting",
        description: "Practice your pitch...",
        imageName: "Presenting",
        duration: 9
    )
    
    ContextScenarioView(scenario: sampleScenario)
}
