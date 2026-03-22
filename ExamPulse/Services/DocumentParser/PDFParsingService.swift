import Foundation
import PDFKit

struct PDFParsingService: DocumentParsingService {
    func extractText(from fileURL: URL) async throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw DocumentParsingError.fileNotFound
        }

        guard let document = PDFDocument(url: fileURL) else {
            throw DocumentParsingError.parsingFailed("Could not open PDF document.")
        }

        var fullText = ""
        for pageIndex in 0..<document.pageCount {
            if let page = document.page(at: pageIndex), let pageText = page.string {
                fullText += pageText + "\n"
            }
        }

        let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw DocumentParsingError.parsingFailed("PDF contains no extractable text.")
        }

        return trimmed
    }
}
