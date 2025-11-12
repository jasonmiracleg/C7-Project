//
//  RandomScenarioViewModel.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 27/10/25.
//

import Foundation
import Combine

@MainActor
class RandomScenarioViewModel: ObservableObject {
    
    @Published var storyBank: [String: [StoryDetail]] = [:]
        
        init() {
            loadStoryData()
        }
        
        func loadStoryData() {
            guard let url = Bundle.main.url(forResource: "StoryData", withExtension: "json") else {
                print("Error: File StoryData.json not found.")
                return
            }

            guard let data = try? Data(contentsOf: url) else {
                print("Error: Failed to load data from flie.")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode([String: [StoryDetail]].self, from: data)
                self.storyBank = decodedData
                print("Bank Cerita successfully loaded.")
            } catch {
                print("Error: Failed to decode StoryData.json  \(error.localizedDescription)")
            }
        }
        
        func getRandomStory(for scenarioTitle: String) -> StoryDetail? {
            guard let storiesForScenario = storyBank[scenarioTitle] else {
                print("Error: No stories found for key'\(scenarioTitle)'")
                return nil
            }
            
            return storiesForScenario.randomElement()
        }
}
