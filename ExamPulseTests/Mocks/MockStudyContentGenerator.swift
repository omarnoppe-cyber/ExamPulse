import Foundation
@testable import ExamPulse

final class MockStudyContentGenerator: StudyContentGenerating {
    var contentToReturn = StudyContent(
        summary: "Mock summary",
        topics: [
            StudyContent.GeneratedTopic(
                title: "Topic A",
                flashcards: [FlashcardDTO(front: "Q1", back: "A1")],
                questions: [QuizQuestionDTO(question: "What?", optionA: "A", optionB: "B", optionC: "C", optionD: "D", correctAnswer: "A", explanation: "A is correct.")]
            )
        ]
    )
    var errorToThrow: Error?
    var generateCalled = false
    var generateFromTextCalled = false

    func generate(from fileURLs: [URL]) async throws -> StudyContent {
        generateCalled = true
        if let error = errorToThrow { throw error }
        return contentToReturn
    }

    func generateFromText(_ text: String) async throws -> StudyContent {
        generateFromTextCalled = true
        if let error = errorToThrow { throw error }
        return contentToReturn
    }
}
