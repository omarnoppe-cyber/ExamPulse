import Foundation
import SwiftData

@Model
final class StudyDocument {
    var id: UUID
    var examId: UUID
    var fileName: String
    var rawText: String
    var summary: String

    var exam: Exam?

    init(
        id: UUID = UUID(),
        examId: UUID,
        fileName: String,
        rawText: String,
        summary: String = ""
    ) {
        self.id = id
        self.examId = examId
        self.fileName = fileName
        self.rawText = rawText
        self.summary = summary
    }
}
