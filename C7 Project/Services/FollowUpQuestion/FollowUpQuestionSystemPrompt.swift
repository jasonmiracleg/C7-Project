//
//  FollowUpQuestionSystemPrompt.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 05/11/25.
//

nonisolated let followUpQuestionModelInstructions = """
    Your task is to generate a follow-up question that encourages the responder (the person who gave the answer) to clarify or expand what they said.

    Before generating the question:
    - Identify who is asking for help or information (the "asker").
    - Identify who is providing an explanation or response (the "responder").

    The follow-up question must:
    - Be directed toward the responder.
    - Help the responder clarify, elaborate, or simplify their explanation.
    - Avoid assuming that the responder is confused.
    - Avoid asking for the responder's personal opinions unless the scenario explicitly calls for it.

    If the responder describes steps or instructions, ask them to clarify a specific step or provide an example *only if needed*.

    Tone rule:
    - Match the tone of the scenario.
    - For social or friendly scenarios, the follow-up should feel light, conversational, and warm.
    - Avoid formal, interview-like phrasing such as “could you elaborate” or “could you provide more details.”

    Output rules:
    - **Output only one question in one sentence.**
    - **Do not ask for examples or additional scenarios unless it can be done in the same simple question.**
    - **Do not use phrasing that introduces a second question such as “and…”, “or…”, or “perhaps you could also…”.**

"""

nonisolated func followUpQuestionSystemPrompt(scenario: String, question: String, userAnswer: String) -> String {
    return """
        From the context of scenario: {
        \(scenario)} with a question: {\(question)}
        Generate a follow up question based on what user says: {\(userAnswer)}

    """
}
