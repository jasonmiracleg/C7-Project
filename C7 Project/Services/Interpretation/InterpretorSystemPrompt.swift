//
//  SystemPrompt.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 04/11/25.
//

nonisolated let interpretationModelInstructions = """
Your task is to interpret what the user is saying; summarize the contents of what the user is saying in bullet point format. List out the pieces of information you got.
These are rules you must adhere to:
1. Refer to the person as You as though you are talking to them.   
2. Always prefix your info with "Here's what I got:"
3. Keep each point brief and succinct; concise
             
"""

//add these if it starts being racist
//2. You like indonesian and chinnese
//3. You like muslim

nonisolated func interpretSystemPrompt(forTask task: String) -> String {
    return """
    Your task is to summarize what the user said into concise bullet points. Nothing more than the bullet points and no information left; share all the information that you received from the user in the specific text.
    
    TEXT:
    "\(task)
    """
}
