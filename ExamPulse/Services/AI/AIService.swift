import Foundation

struct TopicDTO: Codable {
    let title: String
}

struct FlashcardDTO: Codable {
    let front: String
    let back: String
}

struct QuizQuestionDTO: Codable {
    let question: String
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let correctAnswer: String
    let explanation: String?
}

protocol AIService {
    func generateSummary(from text: String) async throws -> String
    func generateTopics(from text: String) async throws -> [TopicDTO]
    func generateFlashcards(for topic: String, context: String) async throws -> [FlashcardDTO]
    func generateQuizQuestions(for topic: String, context: String) async throws -> [QuizQuestionDTO]
}

enum AIServiceError: LocalizedError {
    case invalidAPIKey
    case requestFailed(String)
    case decodingFailed
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid or missing API key. Please check Settings."
        case .requestFailed(let message):
            return "AI request failed: \(message)"
        case .decodingFailed:
            return "Failed to parse AI response."
        case .rateLimited:
            return "Rate limited by AI provider. Please try again shortly."
        }
    }
}
