import Foundation
import SwiftData

@Model
final class Flashcard {
    var id: UUID
    var examId: UUID
    var topicId: UUID
    var front: String
    var back: String
    var reviewCount: Int
    var difficultyScore: Double
    var lastReviewedAt: Date?
    var isLearned: Bool
    var intervalDays: Double
    var nextReviewDate: Date?

    var exam: Exam?
    var topic: Topic?

    var isDue: Bool {
        guard let nextReviewDate else { return true }
        return nextReviewDate <= .now
    }

    init(
        id: UUID = UUID(),
        examId: UUID,
        topicId: UUID,
        front: String,
        back: String,
        reviewCount: Int = 0,
        difficultyScore: Double = 0,
        lastReviewedAt: Date? = nil,
        isLearned: Bool = false,
        intervalDays: Double = 0,
        nextReviewDate: Date? = nil
    ) {
        self.id = id
        self.examId = examId
        self.topicId = topicId
        self.front = front
        self.back = back
        self.reviewCount = reviewCount
        self.difficultyScore = difficultyScore
        self.lastReviewedAt = lastReviewedAt
        self.isLearned = isLearned
        self.intervalDays = intervalDays
        self.nextReviewDate = nextReviewDate
    }

    convenience init(front: String, back: String, isLearned: Bool = false) {
        self.init(examId: UUID(), topicId: UUID(), front: front, back: back, isLearned: isLearned)
    }
}
