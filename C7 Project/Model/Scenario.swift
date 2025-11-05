//
//  Scenario.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 27/10/25.
//

import Foundation

struct Scenario: Codable, Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let duration: Int
}

struct StoryDetail: Codable, Identifiable, Hashable {
    var id: UUID
    var mainTopic: String
    var storyContext: String
    var initialPrompt: String
    
    private enum CodingKeys: String, CodingKey {
        case mainTopic, storyContext, initialPrompt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.mainTopic = try container.decode(String.self, forKey: .mainTopic)
        self.storyContext = try container.decode(String.self, forKey: .storyContext)
        self.initialPrompt = try container.decode(String.self, forKey: .initialPrompt)
        
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), mainTopic: String, storyContext: String, initialPrompt: String) {
        self.id = id
        self.mainTopic = mainTopic
        self.storyContext = storyContext
        self.initialPrompt = initialPrompt
    }
}
