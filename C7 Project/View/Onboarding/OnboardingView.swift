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
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .font(.default)
                    }
                    .padding(.top, 38)
                    
                    Spacer(minLength: 24)
                        
                    PageIndicatorDots(totalSteps: steps.count, currentStep: step)
                        .padding(.bottom, 48)
                    
                    Button(action: {
                        step += 1
                        if step > 2 {
                            step = 2
                        }
                    }) {
                        HStack{
                            Text(step < 2 ? "NEXT PAGE" : "GET STARTED")
                                .frame(maxWidth: .infinity)
                                .font(.title3)
                                .fontWeight(.bold)
                            Image(systemName:"arrow.right")
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 100)
                    .padding(.bottom, 24)
                    
                }
                .frame(height: UIScreen.main.bounds.height * 0.45)
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

#Preview {
    OnboardingHalfModalView()
}
