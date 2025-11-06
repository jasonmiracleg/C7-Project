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
                        .foregroundStyle(.black)
                        .clipShape(Circle())
                }
                .buttonStyle(.glass)
            }
            
            Spacer()
            
            if let story = selectedStory {
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
                            .offset(x: -40, y: 20)
                    }
                Image("Context")
                    .resizable()
                    .frame(width: 350, height: 350)
                    .padding(.top, -24)
                Spacer()
                
                Button("START YOUR CONVERSATION") {
                    showGameplaySheet = true
                }
                .font(.headline)
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(Color.accentColor.opacity(0.8))
                )
                .foregroundStyle(Color.white)
                
            } else {
                ProgressView("Loading Story...")
                Text(scenario.title)
            }
        }
        .padding(.horizontal, 24)
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
        .padding(.horizontal, 24)
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
