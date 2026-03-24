import Foundation
import SwiftData

enum ExamStatus: String, Codable, CaseIterable {
    case new
    case parsing
    case generating
    case ready
    case error
}

@Model
final class Exam {
    var id: UUID
    var title: String
    var examDate: Date
    var createdAt: Date
    var dailyQuestionGoal: Int
    var statusRaw: String

    @Relationship(deleteRule: .cascade, inverse: \StudyDocument.exam)
    var studyDocuments: [StudyDocument]

    @Relationship(deleteRule: .cascade, inverse: \Topic.exam)
    var topics: [Topic]

    @Relationship(deleteRule: .cascade, inverse: \Flashcard.exam)
    var flashcards: [Flashcard]

    @Relationship(deleteRule: .cascade, inverse: \Question.exam)
    var questions: [Question]

    var status: ExamStatus {
        get { ExamStatus(rawValue: statusRaw) ?? .new }
        set { statusRaw = newValue.rawValue }
    }

    /// Calendar days from today’s date to the exam date (midnight-to-midnight), matching `Date.relativeDayDescription`.
    var daysUntilExam: Int {
        let calendar = Calendar.current
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: .now),
            to: calendar.startOfDay(for: examDate)
        ).day ?? 0
    }

    var summaryText: String {
        studyDocuments
            .map(\.summary)
            .first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
            ?? ""
    }

    init(
        id: UUID = UUID(),
        title: String,
        examDate: Date,
        createdAt: Date = Date(),
        dailyQuestionGoal: Int = 10
    ) {
        self.id = id
        self.title = title
        self.examDate = examDate
        self.createdAt = createdAt
        self.dailyQuestionGoal = dailyQuestionGoal
        self.statusRaw = ExamStatus.new.rawValue
        self.studyDocuments = []
        self.topics = []
        self.flashcards = []
        self.questions = []
    }
}
