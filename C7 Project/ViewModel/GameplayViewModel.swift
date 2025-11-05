//
//  GameplayViewModel.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 27/10/25.
//

import Foundation
import Combine

@MainActor
class GameplayViewModel: ObservableObject {
    
    @Published var storyBank: [String: [StoryDetail]] = [:]
        
        init() {
            loadStoryData()
        }
        
        func loadStoryData() {
            guard let url = Bundle.main.url(forResource: "StoryData", withExtension: "json") else {
                print("Error: File StoryData.json tidak ditemukan.")
                return
            }

            guard let data = try? Data(contentsOf: url) else {
                print("Error: Gagal memuat data dari file.")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode([String: [StoryDetail]].self, from: data)
                self.storyBank = decodedData
                print("Bank Cerita berhasil di-load.")
            } catch {
                print("Error: Gagal men-decode StoryData.json. \(error.localizedDescription)")
            }
        }
        
        func getRandomStory(for scenarioTitle: String) -> StoryDetail? {
            guard let storiesForScenario = storyBank[scenarioTitle] else {
                print("Error: Tidak ada cerita ditemukan untuk key '\(scenarioTitle)'")
                return nil
            }
            
            return storiesForScenario.randomElement()
        }
}
