import Foundation

struct OpenAIService: AIService {
    private let apiKeyManager: APIKeyManaging
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let model = "gpt-4o-mini"

    init(apiKeyManager: APIKeyManaging) {
        self.apiKeyManager = apiKeyManager
    }

    // MARK: - AIService

    func generateSummary(from text: String) async throws -> String {
        let prompt = """
        You are an expert study assistant. Create a comprehensive yet concise summary of the following study material. \
        Use markdown formatting with headers, bullet points, and bold text for key terms. \
        Focus on the most important concepts a student needs to know for an exam.

        Study material:
        \(text.prefix(12000))
        """

        return try await sendChatRequest(prompt: prompt)
    }

    func generateTopics(from text: String) async throws -> [TopicDTO] {
        let prompt = """
        Analyze the following study material and extract the main topics/chapters. \
        Return a JSON array of objects with a "title" field. \
        Return between 3 and 10 topics. Only return the JSON array, no other text.

        Example: [{"title": "Photosynthesis"}, {"title": "Cell Division"}]

        Study material:
        \(text.prefix(12000))
        """

        let response = try await sendChatRequest(prompt: prompt)
        return try decodeJSON([TopicDTO].self, from: response)
    }

    func generateFlashcards(for topic: String, context: String) async throws -> [FlashcardDTO] {
        let prompt = """
        Create 5-8 study flashcards for the topic "\(topic)" based on the study material below. \
        Each flashcard should have a "front" (question or term) and "back" (answer or definition). \
        Return a JSON array. Only return the JSON array, no other text.

        Example: [{"front": "What is mitosis?", "back": "Cell division producing two identical daughter cells."}]

        Study material:
        \(context.prefix(8000))
        """

        let response = try await sendChatRequest(prompt: prompt)
        return try decodeJSON([FlashcardDTO].self, from: response)
    }

    func generateQuizQuestions(for topic: String, context: String) async throws -> [QuizQuestionDTO] {
        let prompt = """
        Create 5 multiple-choice quiz questions for the topic "\(topic)" based on the study material below. \
        Each question must have exactly 4 options (optionA, optionB, optionC, optionD) and a correctAnswer \
        that matches one of the options exactly. \
        Return a JSON array. Only return the JSON array, no other text.

        Example: [{"question": "What organelle produces ATP?", "optionA": "Nucleus", "optionB": "Mitochondria", \
        "optionC": "Ribosome", "optionD": "Golgi apparatus", "correctAnswer": "Mitochondria"}]

        Study material:
        \(context.prefix(8000))
        """

        let response = try await sendChatRequest(prompt: prompt)
        return try decodeJSON([QuizQuestionDTO].self, from: response)
    }

    // MARK: - Private

    private func sendChatRequest(prompt: String) async throws -> String {
        guard let apiKey = apiKeyManager.apiKey, !apiKey.isEmpty else {
            throw AIServiceError.invalidAPIKey
        }

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 4000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.requestFailed("Invalid response.")
        }

        if httpResponse.statusCode == 429 {
            throw AIServiceError.rateLimited
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIServiceError.requestFailed("HTTP \(httpResponse.statusCode): \(errorBody)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIServiceError.decodingFailed
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func decodeJSON<T: Decodable>(_ type: T.Type, from text: String) throws -> T {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw AIServiceError.decodingFailed
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw AIServiceError.decodingFailed
        }
    }
}
