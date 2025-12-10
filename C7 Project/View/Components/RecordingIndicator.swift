//
//  RecordingIndicator.swift
//  C7 Project
//
//  Created by Maria Angelica Vinesytha Chandrawan on 05/11/25.
//

import SwiftUI

struct RecordingIndicator: View {

    @State private var dot1Scale: CGFloat = 0.5
    @State private var dot2Scale: CGFloat = 0.5
    @State private var dot3Scale: CGFloat = 0.5
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .frame(width: 5, height: 5)
                .scaleEffect(dot1Scale)
            
            Circle()
                .frame(width: 5, height: 5)
                .scaleEffect(dot2Scale)
            
            Circle()
                .frame(width: 5, height: 5)
                .scaleEffect(dot3Scale)
        }
        .foregroundColor(Color.white.opacity(0.7))
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        let animation = Animation.easeInOut(duration: 0.6)
                                 .repeatForever(autoreverses: true)
        
        withAnimation(animation) {
            dot1Scale = 1.0
        }
        
        withAnimation(animation.delay(0.2)) {
            dot2Scale = 1.0
        }
        
        withAnimation(animation.delay(0.4)) {
            dot3Scale = 1.0
        }
    }
}

#Preview {
    RecordingIndicator()
        .padding()
        .background(Color.blue)
}
