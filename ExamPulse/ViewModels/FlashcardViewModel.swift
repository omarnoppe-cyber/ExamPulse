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

        card.reviewCount += 1
        card.lastReviewedAt = .now

        switch rating {
        case .again:
            card.isLearned = false
            card.difficultyScore = min(card.difficultyScore + 1, 5)
        case .hard:
            card.isLearned = false
            card.difficultyScore = min(card.difficultyScore + 0.5, 5)
        case .easy:
            card.isLearned = true
            card.difficultyScore = max(card.difficultyScore - 0.5, 0)
        }

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
