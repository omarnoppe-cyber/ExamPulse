import Foundation

enum SpacedRepetitionScheduler {
    struct Result {
        let intervalDays: Double
        let difficultyScore: Double
        let nextReviewDate: Date
        let isLearned: Bool
    }

    static func schedule(
        card: Flashcard,
        rating: FlashcardViewModel.ReviewRating,
        now: Date = .now
    ) -> Result {
        let currentInterval = card.intervalDays
        let currentDifficulty = card.difficultyScore

        let newInterval: Double
        let newDifficulty: Double
        let learned: Bool

        switch rating {
        case .again:
            newInterval = 0
            newDifficulty = min(currentDifficulty + 1, 5)
            learned = false

        case .hard:
            let base = max(currentInterval, 1)
            newInterval = base * 1.2
            newDifficulty = min(currentDifficulty + 0.5, 5)
            learned = false

        case .easy:
            let base = max(currentInterval, 1)
            let difficultyBonus = max(1.3 - currentDifficulty * 0.1, 1.0)
            newInterval = base * 2.5 * difficultyBonus
            newDifficulty = max(currentDifficulty - 0.5, 0)
            learned = true
        }

        let nextReview: Date
        if newInterval < 1 {
            nextReview = Calendar.current.date(byAdding: .minute, value: 10, to: now) ?? now
        } else {
            let seconds = newInterval * 86400
            nextReview = now.addingTimeInterval(seconds)
        }

        return Result(
            intervalDays: newInterval,
            difficultyScore: newDifficulty,
            nextReviewDate: nextReview,
            isLearned: learned
        )
    }
}
