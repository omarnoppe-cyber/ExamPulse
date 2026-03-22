import Foundation
import Observation

@Observable
final class QuizViewModel {
    var currentIndex = 0
    var selectedAnswer: String?
    var hasAnswered = false
    var correctCount = 0
    var answers: [String?]

    let questions: [QuizQuestion]

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var isFinished: Bool {
        currentIndex >= questions.count
    }

    var scorePercentage: Int {
        guard !questions.isEmpty else { return 0 }
        return Int(Double(correctCount) / Double(questions.count) * 100)
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    init(questions: [QuizQuestion]) {
        self.questions = questions
        self.answers = Array(repeating: nil, count: questions.count)
    }

    func selectAnswer(_ answer: String) {
        guard !hasAnswered else { return }
        selectedAnswer = answer
    }

    func confirmAnswer() {
        guard let selected = selectedAnswer, !hasAnswered else { return }
        hasAnswered = true
        answers[currentIndex] = selected

        if selected == currentQuestion?.correctAnswer {
            correctCount += 1
        }
    }

    func nextQuestion() {
        currentIndex += 1
        selectedAnswer = nil
        hasAnswered = false
    }

    func restart() {
        currentIndex = 0
        selectedAnswer = nil
        hasAnswered = false
        correctCount = 0
        answers = Array(repeating: nil, count: questions.count)
    }
}
