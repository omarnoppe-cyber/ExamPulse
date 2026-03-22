import Foundation
@testable import ExamPulse

final class MockAIService: AIService {
    var summaryToReturn = "Mock summary content"
    var topicsToReturn: [TopicDTO] = [
        TopicDTO(title: "Topic A"),
        TopicDTO(title: "Topic B")
    ]
    var flashcardsToReturn: [FlashcardDTO] = [
        FlashcardDTO(front: "Q1", back: "A1"),
        FlashcardDTO(front: "Q2", back: "A2")
    ]
    var quizQuestionsToReturn: [QuizQuestionDTO] = [
        QuizQuestionDTO(question: "What?", optionA: "A", optionB: "B", optionC: "C", optionD: "D", correctAnswer: "A")
    ]
    var errorToThrow: Error?

    var generateSummaryCalled = false
    var generateTopicsCalled = false
    var generateFlashcardsCalled = false
    var generateQuizQuestionsCalled = false

    func generateSummary(from text: String) async throws -> String {
        generateSummaryCalled = true
        if let error = errorToThrow { throw error }
        return summaryToReturn
    }

    func generateTopics(from text: String) async throws -> [TopicDTO] {
        generateTopicsCalled = true
        if let error = errorToThrow { throw error }
        return topicsToReturn
    }

    func generateFlashcards(for topic: String, context: String) async throws -> [FlashcardDTO] {
        generateFlashcardsCalled = true
        if let error = errorToThrow { throw error }
        return flashcardsToReturn
    }

    func generateQuizQuestions(for topic: String, context: String) async throws -> [QuizQuestionDTO] {
        generateQuizQuestionsCalled = true
        if let error = errorToThrow { throw error }
        return quizQuestionsToReturn
    }
}
