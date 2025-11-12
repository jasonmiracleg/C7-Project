//
//  ScenarioView.swift
//  C7 Project
//
//  Created by Maria Angelica Vinesytha Chandrawan on 01/11/25.
//

import SwiftUI
import FoundationModels

struct ScenarioView: View {
    @State private var selectedScenario: Scenario?
    
    private var model = SystemLanguageModel.default
    @State private var showAlert = false
    @State private var availabilityMessage = ""
    

    let scenariosData: [Scenario] = [
        Scenario(title: "Presenting", description: "Practice your pitch and presentation skills in time-limited scenarios.", imageName: "Presenting", duration: 9),
        Scenario(title: "Collaborating", description: "Work together with team members to achieve common goals.", imageName: "Collaborating", duration: 6),
        Scenario(title: "Explaining", description: "Break down complex concepts into simple, understandable terms.", imageName: "Explaining", duration: 5),
        Scenario(title: "Reporting", description: "Present data and insights clearly to stakeholders.", imageName: "Reporting", duration: 5),
        Scenario(title: "Networking", description: "Build professional connections and expand your network effectively.", imageName: "Networking", duration: 10)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(scenariosData) { scenario in
                        Button(action: {
                            handleScenarioTap(scenario)
                        }) {
                            ScenarioCard(scenario: scenario)
                                .padding(.bottom, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Scenarios")
            .scrollIndicators(.hidden)
        }
        .fullScreenCover(item: $selectedScenario) { scenario in
            ContextScenarioView(scenario: scenario)
        }
        .alert("Apple Intelligence Unavailable", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(availabilityMessage)
        }
    }
    
    private func handleScenarioTap(_ scenario: Scenario) {
        switch model.availability {
        case .available:
            selectedScenario = scenario
        case .unavailable(.deviceNotEligible):
            availabilityMessage = "This device does not have Apple Intelligence."
            showAlert = true
        case .unavailable(.appleIntelligenceNotEnabled):
            availabilityMessage = "Please enable Apple Intelligence in Settings."
            showAlert = true
        case .unavailable(.modelNotReady):
            availabilityMessage = "Apple Intelligence is still loading. Try again in a moment."
            showAlert = true
        case .unavailable(let reason):
            availabilityMessage = "Unavailable: \(String(describing: reason))"
            showAlert = true
        }
    }
}

#Preview {
    ScenarioView()
}
