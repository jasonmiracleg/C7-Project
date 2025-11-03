//
//  ScenarioCard.swift
//  C7 Project
//
//  Created by Maria Angelica Vinesytha Chandrawan on 01/11/25.
//

import SwiftUI

struct ScenarioCard: View {
    let scenario: Scenario

    var body: some View {
        HStack(spacing: 0) {
            Image(scenario.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .padding(.leading, 4)


            VStack(alignment: .leading, spacing: 8) {
                Text(scenario.title)
                    .font(.title3.bold())
                
                Text(scenario.description)
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
                    .padding(.top, -4)
                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(scenario.duration) minutes")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                
            }
//            .padding(8)
            .frame(width: 180)
        }
        .frame(width: 330, height: 150)
        .background(Color.backgroundComponent)
        .cornerRadius(16)
    }
}

#Preview {
    let sampleScenario = Scenario(
        title: "Presenting",
        description: "Practice your pitch and presentation skills in time-limited scenarios",
        imageName: "Presenting",
        duration: 9
    )
    
    return ScenarioCard(scenario: sampleScenario)
        .padding()
        .background(Color(.systemGroupedBackground))
}
