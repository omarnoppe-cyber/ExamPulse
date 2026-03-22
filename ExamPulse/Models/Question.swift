import Foundation
import SwiftData

@Model
final class Question {
    var id: UUID
    var examId: UUID
    var topicId: UUID
    var prompt: String
    var options: [String]
    var correctAnswer: String
    var explanation: String
    var type: String

    var exam: Exam?
    var topic: Topic?

    @Relationship(deleteRule: .cascade, inverse: \AnswerAttempt.question)
    var answerAttempts: [AnswerAttempt]

    init(
        id: UUID = UUID(),
        examId: UUID,
        topicId: UUID,
        prompt: String,
        options: [String],
        correctAnswer: String,
        explanation: String,
        type: String
    ) {
        self.id = id
        self.examId = examId
        self.topicId = topicId
        self.prompt = prompt
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.type = type
        self.answerAttempts = []
    }
}
