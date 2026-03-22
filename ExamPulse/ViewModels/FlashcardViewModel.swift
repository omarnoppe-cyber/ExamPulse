import Foundation
import Observation

@Observable
final class FlashcardViewModel {
    enum ReviewRating {
        case again
        case hard
        case easy
    }

    var currentIndex = 0
    var isShowingBack = false

    let flashcards: [Flashcard]

    var currentCard: Flashcard? {
        guard currentIndex < flashcards.count else { return nil }
        return flashcards[currentIndex]
    }

    var progress: Double {
        guard !flashcards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(flashcards.count)
    }

    var learnedCount: Int {
        flashcards.filter(\.isLearned).count
    }

    var isFinished: Bool {
        currentIndex >= flashcards.count
    }

    init(flashcards: [Flashcard]) {
        self.flashcards = flashcards
    }

    func flip() {
        isShowingBack.toggle()
    }

    func review(_ rating: ReviewRating) {
        guard let card = currentCard else { return }

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: rating)

        card.reviewCount += 1
        card.lastReviewedAt = .now
        card.intervalDays = result.intervalDays
        card.difficultyScore = result.difficultyScore
        card.nextReviewDate = result.nextReviewDate
        card.isLearned = result.isLearned

        advance()
    }

    func markLearned() {
        review(.easy)
    }

    func markNotLearned() {
        review(.again)
    }

    func restart() {
        currentIndex = 0
        isShowingBack = false
    }

    private func advance() {
        isShowingBack = false
        currentIndex += 1
    }
}
