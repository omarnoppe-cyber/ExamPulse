import Foundation

enum StudyMaterialPrompts {
    static let systemMessage = """
        You are a university professor preparing a student for an upcoming exam. \
        You are precise, thorough, and pedagogically rigorous. \
        Every piece of content you produce must be directly relevant to the study material provided. \
        Always respond with valid JSON only — no markdown fences, no commentary, no extra text.
        """

    static func summary(from text: String) -> String {
        """
        Analyze the following study material and produce a concise exam-preparation summary.

        Requirements:
        - Use markdown: ## headers for major sections, **bold** for key terms, bullet points for supporting details.
        - Prioritize concepts most likely to appear on an exam.
        - Keep the summary under 800 words.

        Respond with a JSON object:
        {"summary": "<markdown string>"}

        Study material:
        \(text.prefix(12000))
        """
    }

    static func topics(from text: String) -> String {
        """
        Identify the main exam-relevant topics in the study material below.

        Requirements:
        - Return between 3 and 10 topics.
        - Each topic title should be specific enough to study independently.
        - Order topics from most fundamental to most advanced.

        Respond with a JSON array:
        [{"title": "Topic Name"}, ...]

        Study material:
        \(text.prefix(12000))
        """
    }

    static func flashcards(for topic: String, context: String) -> String {
        """
        Create 5–8 study flashcards for the topic "\(topic)".

        Requirements:
        - "front": a clear question, term, or prompt a student should be able to answer.
        - "back": a concise, accurate answer or definition (1–3 sentences).
        - Cover the most important facts, definitions, and relationships for this topic.
        - Do not repeat information across cards.

        Respond with a JSON array:
        [{"front": "...", "back": "..."}, ...]

        Study material:
        \(context.prefix(8000))
        """
    }

    static func questions(for topic: String, context: String) -> String {
        """
        Create 5 multiple-choice exam questions for the topic "\(topic)".

        Requirements:
        - Each question must have exactly 4 options labeled optionA through optionD.
        - Exactly one option is correct; the other three must be plausible distractors.
        - "correctAnswer" must match one of the four options exactly.
        - "explanation" must briefly explain why the correct answer is right (1–2 sentences).
        - Questions should test understanding, not just recall.

        Respond with a JSON array:
        [
          {
            "question": "...",
            "optionA": "...",
            "optionB": "...",
            "optionC": "...",
            "optionD": "...",
            "correctAnswer": "...",
            "explanation": "..."
          }
        ]

        Study material:
        \(context.prefix(8000))
        """
    }
}
