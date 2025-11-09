//
//  OnboardingModal.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 31/10/25.
//

import Foundation
import SwiftUI

struct OnboardingStepData {
    let image: String
    let title: String
    let description: String
}

struct OnboardingHalfModalView: View {
    @Binding var currentAppState: AppState
    
    @State private var step = 0
    
    private let steps: [OnboardingStepData] = [
        OnboardingStepData(image: "Onboarding1", title: "Welcome to Gerald App!", description: "This app is designed to help you speak more confidently with instant feedback from AI."),
        OnboardingStepData( image: "Onboarding2", title: "Choose a Scenario to Practice", description: "Pick from a variety of scenarios based on your interests and needs."),
        OnboardingStepData(image: "Onboarding3", title: "Practice and Improve", description: "Answer questions by speaking, and AI will instantly analyze your pronunciation, grammar, and content to help you grow."),
    ]
    
    var body: some View {
        VStack (spacing: 0) {
            
            TabView(selection: $step) {
                ForEach(steps.indices, id: \.self) { index in
                    Image(steps[index].image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(24)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack() {
                VStack {
                    Text(steps[step].title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 16)
                        .foregroundStyle(Color.main)
                    
                    Text(steps[step].description)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .font(.default)
                }
                .id("text_\(step)")
                .padding(.top, 38)
                
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                Spacer(minLength: 24)
                
                PageIndicatorDots(totalSteps: steps.count, currentStep: step)
                    .padding(.bottom, 48)
                
                HStack {
                    Button(action: {
                        currentAppState = .disclaimer
                    }) {
                        Text("SKIP")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.main)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if step < (steps.count - 1) {
                            withAnimation {
                                step += 1
                            }
                        } else {
                            currentAppState = .disclaimer
                        }
                    }) {
                        HStack {
                            Text(step < (steps.count - 1) ? "NEXT" : "GET STARTED")
                                .font(.headline)
                                .fontWeight(.bold)
                            if step == (steps.count - 1) {
                                Image(systemName:"arrow.right")
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.main)
                        .foregroundColor(.white)
                        .cornerRadius(50)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: 350)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                //                    .shadow(radius: 10)
            )
            
//            .animation(.easeInOut, value: step)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(.main)
    }
}

#Preview {
    OnboardingHalfModalView(currentAppState: .constant(.onboarding))
}
