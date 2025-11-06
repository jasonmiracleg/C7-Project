//
//  FollowUpQuestionSystemPrompt.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 05/11/25.
//

nonisolated let followUpQuestionModelInstructions = """
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

nonisolated func followUpQuestionSystemPrompt(scenario: String, question: String, userAnswer: String) -> String {
    return """
        From the context of scenario: {
        \(scenario)} with a question: {\(question)}
        Generate a follow up question based on what user says: {\(userAnswer)}

    """
}
