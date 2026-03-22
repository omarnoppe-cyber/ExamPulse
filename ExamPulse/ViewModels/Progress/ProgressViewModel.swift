import Foundation
import Observation

@Observable
final class ProgressViewModel {
    func readyExamCount(in exams: [Exam]) -> Int {
        exams.filter { $0.status == .ready }.count
    }

    func activeExamCount(in exams: [Exam]) -> Int {
        exams.filter { $0.status == .new || $0.status == .parsing || $0.status == .generating }.count
    }

    func learnedFlashcards(in exams: [Exam]) -> Int {
        exams.flatMap(\.topics).flatMap(\.flashcards).filter(\.isLearned).count
    }

    func totalFlashcards(in exams: [Exam]) -> Int {
        exams.flatMap(\.topics).flatMap(\.flashcards).count
    }
}
