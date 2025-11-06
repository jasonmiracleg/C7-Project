//
//  ErrorTaggingPlayground.swift
//  C7 Project
//
//  Created by Savio Enoson on 03/11/25.
//

import SwiftUI
import Foundation
import FoundationModels
import NaturalLanguage
import Playgrounds


#Playground {
    let analyst = GrammarAnalyst()
    
    let paragraph = """
    My friend just finished his final exams, so we're all very happy for him. We are planning to do a party for his graduation this weekend. He's inviting a lot of people from his class. I'm going to bring a cake, but I'll make sure it's not too sweet.``
    """
    
    let (correctedText, errorFlags) = try await analyst.runAnalysisForTuning(on: paragraph, category: .CollocationError, doValidation: true)
    
    print("FLAGS-----------------\n")
    let allFlags = errorFlags
    for flag in allFlags {
        print(flag)
    }
    
    //    let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
    //    let session = LanguageModelSession(model: model, instructions: testTaggerSystemPrompt)
    //
    //    let response = try await session.respond(
    //        to: testFlaggingInputPrompt(task: paragraph),
    //        generating: [ErrorFlag].self,
    //        options: GenerationOptions(sampling: .greedy, temperature: 0.5)
    //    )
}
