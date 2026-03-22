import Foundation
import SwiftData
@testable import ExamPulse

enum TestModelContainer {
    @MainActor
    static func create() throws -> ModelContainer {
        let schema = Schema([
            Exam.self,
            Document.self,
            Summary.self,
            Topic.self,
            Flashcard.self,
            QuizQuestion.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
