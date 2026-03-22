import Foundation
import SwiftData

@Model
final class AnswerAttempt {
    var id: UUID
    var questionId: UUID
    var answeredAt: Date
    var wasCorrect: Bool

    var question: Question?

    init(
        id: UUID = UUID(),
        questionId: UUID,
        answeredAt: Date = Date(),
        wasCorrect: Bool
    ) {
        self.id = id
        self.questionId = questionId
        self.answeredAt = answeredAt
        self.wasCorrect = wasCorrect
    }
}
