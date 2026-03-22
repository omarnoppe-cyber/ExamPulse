import Foundation
import SwiftData
@testable import ExamPulse

enum TestModelContainer {
    @MainActor
    static func create() throws -> ModelContainer {
        let schema = Schema([
            Exam.self,
            StudyDocument.self,
            Topic.self,
            Flashcard.self,
            Question.self,
            AnswerAttempt.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
