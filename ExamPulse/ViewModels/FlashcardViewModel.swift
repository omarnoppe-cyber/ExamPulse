import Foundation
import Observation

@Observable
final class FlashcardViewModel {
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

    func markLearned() {
        currentCard?.isLearned = true
        advance()
    }

    func markNotLearned() {
        currentCard?.isLearned = false
        advance()
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
