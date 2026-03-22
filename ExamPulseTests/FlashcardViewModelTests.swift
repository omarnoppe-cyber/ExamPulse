import Testing
import Foundation
@testable import ExamPulse

struct FlashcardViewModelTests {
    private func makeCards() -> [Flashcard] {
        [
            Flashcard(front: "Q1", back: "A1"),
            Flashcard(front: "Q2", back: "A2"),
            Flashcard(front: "Q3", back: "A3")
        ]
    }

    @Test func markLearnedAdvancesAndSetsFlag() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.flip()
        vm.markLearned()
        #expect(cards[0].isLearned == true)
        #expect(vm.currentIndex == 1)
    }

    @Test func markNotLearnedAdvancesWithoutFlag() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.flip()
        vm.markNotLearned()
        #expect(cards[0].isLearned == false)
        #expect(vm.currentIndex == 1)
    }

    @Test func learnedCountTracksCorrectly() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.markLearned()
        vm.markLearned()
        #expect(vm.learnedCount == 2)
    }

    @Test func finishesAfterAllCardsProcessed() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.markLearned()
        vm.markNotLearned()
        vm.markLearned()
        #expect(vm.isFinished == true)
    }
}
