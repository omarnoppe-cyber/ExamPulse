import Foundation
import SwiftData

@Model
final class Topic {
    var id: UUID
    var title: String
    var sortOrder: Int

    var exam: Exam?

    @Relationship(deleteRule: .cascade, inverse: \Flashcard.topic)
    var flashcards: [Flashcard]

    @Relationship(deleteRule: .cascade, inverse: \QuizQuestion.topic)
    var quizQuestions: [QuizQuestion]

    var learnedFlashcardsCount: Int {
        flashcards.filter(\.isLearned).count
    }

    init(title: String, sortOrder: Int) {
        self.id = UUID()
        self.title = title
        self.sortOrder = sortOrder
        self.flashcards = []
        self.quizQuestions = []
    }
}
