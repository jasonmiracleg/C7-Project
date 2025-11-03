//
//  Scenario.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 27/10/25.
//

import Foundation

struct Scenario: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let duration: Int
}
