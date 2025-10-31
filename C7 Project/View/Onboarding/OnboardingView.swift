//
//  OnboardingModal.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 31/10/25.
//

import Foundation
import SwiftUI

struct OnboardingStepData {
    let title: String
    let description: String
}

struct OnboardingHalfModalView: View {
    @State private var showModal = true
    @State private var step = 0
    
    private let steps: [OnboardingStepData] = [
        OnboardingStepData(title: "Welcome to Gerald App!", description: "This app is designed to help you speak with more confidence! Choose a scenario, answer the questions by speaking, and receive instant feedback from AI. Let’s start your learning journey now!"),
        OnboardingStepData(title: "Choose a Scenario to Practice", description: "Pick from a variety of scenarios based on your interests and needs. Each scenario offers a different speaking challenge, from presentations to collaborating in meetings. Pick one and start practicing!"),
        OnboardingStepData(title: "Practice and Improve", description: "Answer each question by speaking for a few minutes. Afterward, AI will provide feedback on your pronunciation and content. AI will highlight mistakes and offer suggestions for improvement. Ready to see your progress?"),
    ]
    
    var body: some View {
        ZStack {
//            Main content bit
            Color(.systemBlue)
                .ignoresSafeArea()

            VStack {
//                PUSH IT DOWNN
                Spacer()
                
//                Modal shit here
                VStack() {
                    
                    
                    VStack {
                        Text(steps[step].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 16)
                            .foregroundStyle(Color(.blue))
                            
                        Text(steps[step].description)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .font(.default)
                    }
                    .padding(.top, 38)
                    
                    Spacer(minLength: 24)
                        
                    PageIndicatorDots(totalSteps: steps.count, currentStep: step)
                        .padding(.bottom, 48)
                    
//                    Purely for testing the page indicators
//                    Button(action: {
//                        step -= 1
//                        if step < 0 {
//                            step = 0
//                        }
//                    }) {
//                        Text("Back")
//                    }
                    
                    Button(action: {
                        step += 1
                        if step > 2 {
                            step = 2
                        }
                    }) {
                        Text(step < 2 ? "Next Page" : "Get Started")
                            .frame(maxWidth: .infinity)
                            .font(.title3.bold())
                        
                        ZStack{
//                            I dont wanna figure out the circle color rn
//                            Circle()
//                                .frame(width: 36, height: 36)
//                                .foregroundStyle(Color.gray.opacity(0.7))
                            Image(systemName:"arrow.right")
                        }
                        .padding(.leading, -20)
                        
                        }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 100)
                    .padding(.bottom, 24)
                    
                }
                .frame(height: UIScreen.main.bounds.height / 100 * 45)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(radius: 10)
                )
                .ignoresSafeArea()

            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct PageIndicatorDots: View {
    let totalSteps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0...totalSteps-1, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Color.blue : Color.blue.opacity(0.3))
                    .frame(width: index == currentStep ? 20 : 10,
                           height: 10)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
}

#Preview {
    OnboardingHalfModalView()
}
