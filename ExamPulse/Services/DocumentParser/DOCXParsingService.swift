import Foundation

struct DOCXParsingService: DocumentParsingService {
    func extractText(from fileURL: URL) async throws -> String {
        try DOCXTextExtractor.extractText(from: fileURL)
    }
}

