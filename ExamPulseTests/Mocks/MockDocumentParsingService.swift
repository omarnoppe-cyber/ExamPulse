import Foundation
@testable import ExamPulse

struct MockDocumentParsingService: DocumentParsingService {
    var textToReturn: String
    var errorToThrow: Error?

    init(textToReturn: String = "Parsed document text about biology and chemistry.") {
        self.textToReturn = textToReturn
    }

    func extractText(from fileURL: URL) async throws -> String {
        if let error = errorToThrow { throw error }
        return textToReturn
    }
}
