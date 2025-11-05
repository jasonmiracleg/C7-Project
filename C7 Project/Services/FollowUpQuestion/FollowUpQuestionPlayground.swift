//
//  FollowUpQuestionPlayground.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 05/11/25.
//

import FoundationModels
import Playgrounds

#Playground {
    let instruction = """
        Your task is to generate one follow-up question that encourages the user to share more about what they said. 
        Follow these rules:

        1. Output only one question. Do not add explanations or multiple sentences.
        2. The question must be directly related to the user’s statement.
        3. The question must be light, friendly, and open-ended (avoid yes/no questions).
        4. Do not use long or complex phrasing. Keep the question to one simple sentence.
        5. Do not repeat the user’s wording exactly; rephrase naturally.
        6. Do not include multiple questions in one. Do not use “and” to ask two things at once.
        7. If the user's statement mentions a process or unique term, the following question should ask about the specific detail
        8. If the previous question is included in coversational, the following question should follow the context of the previous session

    """
    
    let session = LanguageModelSession(instructions: instruction)
    
    do {
        let prompt = """
    From the context of scenario: {The CEO of your company is doing an impromptu company visit. Apparently, they are laying off some of the workforce for efficiency. He stops at your desk to ask about your work.} with a question: {So, can you tell me about what you worked on this past week?}
    Generate a follow up question based on what user says: {I've been working on the english speaking app. I need to do some research how do people correct their grammar and pronunciation. However, there's a bug that annoys me for the past few days. Apparently, the microphone doesn't work everytime I press the button}
    """
        let response = try await session.respond(to: prompt)
    } catch {

    }
}
