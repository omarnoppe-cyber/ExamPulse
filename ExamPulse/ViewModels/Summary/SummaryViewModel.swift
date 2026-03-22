import Foundation
import Observation

@Observable
final class SummaryViewModel {
    let summaryText: String
    let topics: [Topic]

    var totalQuestionCount: Int {
        topics.reduce(0) { $0 + $1.questions.count }
    }

    var totalFlashcardCount: Int {
        topics.reduce(0) { $0 + $1.flashcards.count }
    }

    var sortedTopics: [Topic] {
        topics.sorted { $0.sortOrder < $1.sortOrder }
    }

    init(summaryText: String, topics: [Topic]) {
        self.summaryText = summaryText
        self.topics = topics
    }
}
