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

    @Test func easyReviewAdvancesAndSchedules() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.flip()
        vm.review(.easy)
        #expect(cards[0].isLearned == true)
        #expect(cards[0].reviewCount == 1)
        #expect(cards[0].intervalDays > 0)
        #expect(cards[0].nextReviewDate != nil)
        #expect(vm.currentIndex == 1)
    }

    @Test func againReviewResetsInterval() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.flip()
        vm.review(.again)
        #expect(cards[0].isLearned == false)
        #expect(cards[0].intervalDays == 0)
        #expect(cards[0].difficultyScore == 1)
        #expect(vm.currentIndex == 1)
    }

    @Test func hardReviewGrowsIntervalSlowly() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)

        vm.flip()
        vm.review(.hard)

        #expect(cards[0].isLearned == false)
        #expect(cards[0].difficultyScore == 0.5)
        #expect(cards[0].intervalDays == 1.2)
        #expect(cards[0].reviewCount == 1)
    }

    @Test func learnedCountTracksCorrectly() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.review(.easy)
        vm.review(.easy)
        #expect(vm.learnedCount == 2)
    }

    @Test func finishesAfterAllCardsProcessed() {
        let cards = makeCards()
        let vm = FlashcardViewModel(flashcards: cards)
        vm.review(.easy)
        vm.review(.again)
        vm.review(.easy)
        #expect(vm.isFinished == true)
    }
}
