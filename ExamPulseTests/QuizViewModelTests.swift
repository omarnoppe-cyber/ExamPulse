import Testing
import Foundation
@testable import ExamPulse

struct QuizViewModelTests {
    private func makeQuestions() -> [QuizQuestion] {
        [
            QuizQuestion(question: "What is 1+1?", optionA: "1", optionB: "2", optionC: "3", optionD: "4", correctAnswer: "2"),
            QuizQuestion(question: "What is 2+2?", optionA: "3", optionB: "4", optionC: "5", optionD: "6", correctAnswer: "4"),
            QuizQuestion(question: "What is 3+3?", optionA: "5", optionB: "6", optionC: "7", optionD: "8", correctAnswer: "6")
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
