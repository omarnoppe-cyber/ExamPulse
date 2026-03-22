import Foundation
import SwiftData

@Model
final class Document {
    var id: UUID
    var filename: String
    var fileURL: String
    var rawText: String

    var exam: Exam?

    init(filename: String, fileURL: String, rawText: String = "") {
        self.id = UUID()
        self.filename = filename
        self.fileURL = fileURL
        self.rawText = rawText
    }
}
