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
        let response = try await sendChatRequest(
            prompt: StudyMaterialPrompts.summary(from: text)
        )

        struct SummaryResponse: Codable { let summary: String }
        if let parsed = try? decodeJSON(SummaryResponse.self, from: response) {
            return parsed.summary
        }

        return response
    }

    func generateTopics(from text: String) async throws -> [TopicDTO] {
        let response = try await sendChatRequest(
            prompt: StudyMaterialPrompts.topics(from: text)
        )
        return try decodeJSON([TopicDTO].self, from: response)
    }

    func generateFlashcards(for topic: String, context: String) async throws -> [FlashcardDTO] {
        let response = try await sendChatRequest(
            prompt: StudyMaterialPrompts.flashcards(for: topic, context: context)
        )
        return try decodeJSON([FlashcardDTO].self, from: response)
    }

    func generateQuizQuestions(for topic: String, context: String) async throws -> [QuizQuestionDTO] {
        let response = try await sendChatRequest(
            prompt: StudyMaterialPrompts.questions(for: topic, context: context)
        )
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
                ["role": "system", "content": StudyMaterialPrompts.systemMessage],
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
