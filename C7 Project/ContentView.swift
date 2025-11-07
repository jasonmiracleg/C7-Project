//
//  ContentView.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 24/10/25.
//

import Foundation

enum AppState {
    case onboarding
    case disclaimer
    case mainApp
}


import SwiftUI

struct ContentView: View {
    @State private var appState: AppState = .onboarding
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            ScenarioView()
        } else {
            switch appState {
            case .onboarding:
                OnboardingHalfModalView(currentAppState: $appState)
                
            case .disclaimer:
                DisclaimerView(currentAppState: $appState)
                
            case .mainApp:
                ScenarioView()
                    .onAppear {
                        hasCompletedOnboarding = true
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
