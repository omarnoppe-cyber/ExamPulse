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
    var statusRaw: String

    @Relationship(deleteRule: .cascade, inverse: \Document.exam)
    var documents: [Document]

    @Relationship(deleteRule: .cascade, inverse: \Summary.exam)
    var summary: Summary?

    @Relationship(deleteRule: .cascade, inverse: \Topic.exam)
    var topics: [Topic]

    var status: ExamStatus {
        get { ExamStatus(rawValue: statusRaw) ?? .new }
        set { statusRaw = newValue.rawValue }
    }

    var daysUntilExam: Int {
        Calendar.current.dateComponents([.day], from: .now, to: examDate).day ?? 0
    }

    init(title: String, examDate: Date) {
        self.id = UUID()
        self.title = title
        self.examDate = examDate
        self.createdAt = Date()
        self.statusRaw = ExamStatus.new.rawValue
        self.documents = []
        self.topics = []
    }
}
