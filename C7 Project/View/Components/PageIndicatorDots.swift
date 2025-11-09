//
//  PagesIndicator.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 31/10/25.
//

import SwiftUI

struct PageIndicatorDots: View {
    let totalSteps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0...totalSteps-1, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Color.main : Color.main.opacity(0.3))
                    .frame(width: index == currentStep ? 25 : 15,
                           height: 15)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
}
