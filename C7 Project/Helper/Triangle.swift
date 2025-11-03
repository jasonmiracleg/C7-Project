//
//  Triangle.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 03/11/25.
//

import SwiftUI

// For Context Bubble Chat's Tail
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
