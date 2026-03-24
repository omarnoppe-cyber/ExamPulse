import Foundation
import SwiftData
import Observation

@Observable
final class QuizViewModel {
    var currentIndex = 0
    var selectedAnswer: String?
    var hasAnswered = false
    var correctCount = 0
    var answers: [String?]

    let questions: [Question]

    var currentQuestion: Question? {
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

    init(questions: [Question]) {
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

        let isCorrect = selected == currentQuestion?.correctAnswer
        if isCorrect { correctCount += 1 }

        if let question = currentQuestion {
            let attempt = AnswerAttempt(questionId: question.id, wasCorrect: isCorrect)
            attempt.question = question
        }
    }

    func nextQuestion() {
        currentIndex += 1
        selectedAnswer = nil
        hasAnswered = false

        if isFinished {
            updateTopicMastery()
        }
    }

    func restart() {
        currentIndex = 0
        selectedAnswer = nil
        hasAnswered = false
        correctCount = 0
        answers = Array(repeating: nil, count: questions.count)
    }

    private func updateTopicMastery() {
        let topicsByID = Dictionary(grouping: questions, by: { $0.topic?.id })
        for (_, topicQuestions) in topicsByID {
            guard let topic = topicQuestions.first?.topic else { continue }
            let allAttempts = topic.questions.flatMap(\.answerAttempts)
            guard !allAttempts.isEmpty else { continue }
            topic.masteryScore = Double(allAttempts.filter(\.wasCorrect).count) / Double(allAttempts.count)
        }
    }
}
