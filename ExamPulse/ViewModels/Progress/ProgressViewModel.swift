import Foundation
import Observation

@Observable
final class ProgressViewModel {
    func accuracyPercentage(in exams: [Exam]) -> Int {
        let attempts = exams
            .flatMap(\.questions)
            .flatMap(\.answerAttempts)

        guard !attempts.isEmpty else { return 0 }

        let correct = attempts.filter(\.wasCorrect).count
        return Int((Double(correct) / Double(attempts.count)) * 100)
    }

    func flashcardsReviewed(in exams: [Exam]) -> Int {
        exams
            .flatMap(\.flashcards)
            .reduce(0) { $0 + $1.reviewCount }
    }

    func totalFlashcards(in exams: [Exam]) -> Int {
        exams.flatMap(\.flashcards).count
    }

    func flashcardsReviewedProgress(in exams: [Exam]) -> Double {
        let total = totalFlashcards(in: exams)
        guard total > 0 else { return 0 }

        let reviewed = exams
            .flatMap(\.flashcards)
            .filter { $0.reviewCount > 0 }
            .count

        return Double(reviewed) / Double(total)
    }

    func weakTopics(in exams: [Exam]) -> [Topic] {
        exams
            .flatMap(\.topics)
            .sorted { lhs, rhs in
                topicWeaknessScore(lhs) > topicWeaknessScore(rhs)
            }
            .filter { topicWeaknessScore($0) > 0 }
    }

    func daysRemaining(in exams: [Exam]) -> Int? {
        exams
            .filter { $0.examDate >= .now }
            .map(\.daysUntilExam)
            .min()
    }

    func daysRemainingProgress(in exams: [Exam]) -> Double {
        guard let nextExam = exams
            .filter({ $0.examDate >= .now })
            .min(by: { $0.examDate < $1.examDate }) else {
            return 0
        }

        let totalWindow = max(
            Calendar.current.dateComponents([.day], from: nextExam.createdAt, to: nextExam.examDate).day ?? 0,
            1
        )
        let remaining = max(nextExam.daysUntilExam, 0)

        return 1 - (Double(remaining) / Double(totalWindow))
    }

    func topicWeaknessScore(_ topic: Topic) -> Double {
        let attemptAccuracy: Double
        let attempts = topic.questions.flatMap(\.answerAttempts)
        if attempts.isEmpty {
            attemptAccuracy = topic.masteryScore
        } else {
            let correct = attempts.filter(\.wasCorrect).count
            attemptAccuracy = Double(correct) / Double(attempts.count)
        }

        let flashcardProgress: Double
        if topic.flashcards.isEmpty {
            flashcardProgress = 0
        } else {
            flashcardProgress = Double(topic.learnedFlashcardsCount) / Double(topic.flashcards.count)
        }

        let combinedStrength = (attemptAccuracy + flashcardProgress) / 2
        return max(0, 1 - combinedStrength)
    }
}
