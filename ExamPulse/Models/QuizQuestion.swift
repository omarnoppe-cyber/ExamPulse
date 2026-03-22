import Foundation
import SwiftData

@Model
final class QuizQuestion {
    var id: UUID
    var question: String
    var optionA: String
    var optionB: String
    var optionC: String
    var optionD: String
    var correctAnswer: String

    var topic: Topic?

    var options: [String] {
        [optionA, optionB, optionC, optionD]
    }

    init(question: String, optionA: String, optionB: String, optionC: String, optionD: String, correctAnswer: String) {
        self.id = UUID()
        self.question = question
        self.optionA = optionA
        self.optionB = optionB
        self.optionC = optionC
        self.optionD = optionD
        self.correctAnswer = correctAnswer
    }
}
