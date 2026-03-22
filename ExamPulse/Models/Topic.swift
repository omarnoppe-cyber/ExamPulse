import Foundation
import SwiftData

@Model
final class Topic {
    var id: UUID
    var examId: UUID
    var title: String
    var masteryScore: Double
    var sortOrder: Int

    var exam: Exam?

    @Relationship(deleteRule: .cascade, inverse: \Flashcard.topic)
    var flashcards: [Flashcard]

    @Relationship(deleteRule: .cascade, inverse: \Question.topic)
    var questions: [Question]

    var learnedFlashcardsCount: Int {
        flashcards.filter(\.isLearned).count
    }

    init(
        id: UUID = UUID(),
        examId: UUID,
        title: String,
        masteryScore: Double = 0,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.examId = examId
        self.title = title
        self.masteryScore = masteryScore
        self.sortOrder = sortOrder
        self.flashcards = []
        self.questions = []
    }
}
