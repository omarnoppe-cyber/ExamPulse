import Testing
import Foundation
@testable import ExamPulse

struct SpacedRepetitionSchedulerTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func againResetsIntervalToZero() {
        let card = Flashcard(front: "Q", back: "A")
        card.intervalDays = 4
        card.difficultyScore = 1

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: .again, now: now)

        #expect(result.intervalDays == 0)
        #expect(result.difficultyScore == 2)
        #expect(result.isLearned == false)
        #expect(result.nextReviewDate < now.addingTimeInterval(700))
    }

    @Test func hardGrowsIntervalSlowly() {
        let card = Flashcard(front: "Q", back: "A")
        card.intervalDays = 2
        card.difficultyScore = 1

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: .hard, now: now)

        #expect(result.intervalDays == 2.4)
        #expect(result.difficultyScore == 1.5)
        #expect(result.isLearned == false)

        let expectedDate = now.addingTimeInterval(2.4 * 86400)
        #expect(abs(result.nextReviewDate.timeIntervalSince(expectedDate)) < 1)
    }

    @Test func easyGrowsIntervalFast() {
        let card = Flashcard(front: "Q", back: "A")
        card.intervalDays = 1
        card.difficultyScore = 0

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: .easy, now: now)

        #expect(result.intervalDays == 3.25)
        #expect(result.difficultyScore == 0)
        #expect(result.isLearned == true)

        let expectedDate = now.addingTimeInterval(3.25 * 86400)
        #expect(abs(result.nextReviewDate.timeIntervalSince(expectedDate)) < 1)
    }

    @Test func firstReviewEasyUsesBaseOfOneDay() {
        let card = Flashcard(front: "Q", back: "A")

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: .easy, now: now)

        #expect(result.intervalDays > 1)
        #expect(result.isLearned == true)
    }

    @Test func firstReviewHardUsesBaseOfOneDay() {
        let card = Flashcard(front: "Q", back: "A")

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: .hard, now: now)

        #expect(result.intervalDays == 1.2)
        #expect(result.isLearned == false)
    }

    @Test func difficultyClampedAtFive() {
        let card = Flashcard(front: "Q", back: "A")
        card.difficultyScore = 4.5

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: .again, now: now)

        #expect(result.difficultyScore == 5)
    }

    @Test func difficultyClampedAtZero() {
        let card = Flashcard(front: "Q", back: "A")
        card.difficultyScore = 0.2

        let result = SpacedRepetitionScheduler.schedule(card: card, rating: .easy, now: now)

        #expect(result.difficultyScore == 0)
    }

    @Test func highDifficultyReducesEasyMultiplier() {
        let easyCard = Flashcard(front: "Q", back: "A")
        easyCard.intervalDays = 2
        easyCard.difficultyScore = 0

        let hardCard = Flashcard(front: "Q", back: "A")
        hardCard.intervalDays = 2
        hardCard.difficultyScore = 3

        let easyResult = SpacedRepetitionScheduler.schedule(card: easyCard, rating: .easy, now: now)
        let hardResult = SpacedRepetitionScheduler.schedule(card: hardCard, rating: .easy, now: now)

        #expect(easyResult.intervalDays > hardResult.intervalDays)
    }

    @Test func cardIsDueWhenNextReviewDateIsNil() {
        let card = Flashcard(front: "Q", back: "A")
        #expect(card.isDue == true)
    }

    @Test func cardIsDueWhenNextReviewDateIsInThePast() {
        let card = Flashcard(front: "Q", back: "A")
        card.nextReviewDate = Date.distantPast
        #expect(card.isDue == true)
    }

    @Test func cardIsNotDueWhenNextReviewDateIsInTheFuture() {
        let card = Flashcard(front: "Q", back: "A")
        card.nextReviewDate = Date.distantFuture
        #expect(card.isDue == false)
    }
}
