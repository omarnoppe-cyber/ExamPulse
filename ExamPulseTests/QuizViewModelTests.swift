import Testing
import Foundation
@testable import ExamPulse

struct QuizViewModelTests {
    private func makeQuestions() -> [Question] {
        [
            Question(examId: UUID(), topicId: UUID(), prompt: "What is 1+1?", options: ["1", "2", "3", "4"], correctAnswer: "2", explanation: "", type: "multipleChoice"),
            Question(examId: UUID(), topicId: UUID(), prompt: "What is 2+2?", options: ["3", "4", "5", "6"], correctAnswer: "4", explanation: "", type: "multipleChoice"),
            Question(examId: UUID(), topicId: UUID(), prompt: "What is 3+3?", options: ["5", "6", "7", "8"], correctAnswer: "6", explanation: "", type: "multipleChoice")
        ]
    }

    @Test func confirmCorrectAnswerIncrementsScore() {
        let vm = QuizViewModel(questions: makeQuestions())
        vm.selectAnswer("2")
        vm.confirmAnswer()
        #expect(vm.correctCount == 1)
    }

    @Test func confirmWrongAnswerDoesNotIncrementScore() {
        let vm = QuizViewModel(questions: makeQuestions())
        vm.selectAnswer("1")
        vm.confirmAnswer()
        #expect(vm.correctCount == 0)
    }

    @Test func fullQuizScoringCalculatesCorrectly() {
        let vm = QuizViewModel(questions: makeQuestions())

        vm.selectAnswer("2"); vm.confirmAnswer(); vm.nextQuestion()
        vm.selectAnswer("4"); vm.confirmAnswer(); vm.nextQuestion()
        vm.selectAnswer("5"); vm.confirmAnswer(); vm.nextQuestion()

        #expect(vm.correctCount == 2)
        #expect(vm.scorePercentage == 66)
    }

    @Test func perfectScoreIs100Percent() {
        let vm = QuizViewModel(questions: makeQuestions())

        vm.selectAnswer("2"); vm.confirmAnswer(); vm.nextQuestion()
        vm.selectAnswer("4"); vm.confirmAnswer(); vm.nextQuestion()
        vm.selectAnswer("6"); vm.confirmAnswer(); vm.nextQuestion()

        #expect(vm.scorePercentage == 100)
    }
}
