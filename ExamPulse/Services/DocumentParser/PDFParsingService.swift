import Foundation
import PDFKit

struct PDFParsingService: DocumentParsingService {
    func extractText(from url: URL) async throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentParsingError.fileNotFound
        }

        guard let document = PDFDocument(url: url) else {
            throw DocumentParsingError.parsingFailed("Could not open PDF document.")
        }

        let pageTexts = (0..<document.pageCount).compactMap { pageIndex -> String? in
            guard let page = document.page(at: pageIndex),
                  let pageText = page.string else {
                return nil
            }

            let cleanedPageText = normalizeWhitespace(in: pageText)
            return cleanedPageText.isEmpty ? nil : cleanedPageText
        }

        let extractedText = pageTexts.joined(separator: "\n\n")
        guard !extractedText.isEmpty else {
            throw DocumentParsingError.parsingFailed("PDF contains no extractable text.")
        }

        return extractedText
    }

    private func normalizeWhitespace(in text: String) -> String {
        let lines = text
            .components(separatedBy: .newlines)
            .map { line in
                line.replacingOccurrences(
                    of: #"[\t ]+"#,
                    with: " ",
                    options: .regularExpression
                )
                .trimmingCharacters(in: .whitespacesAndNewlines)
            }

        var normalizedLines: [String] = []
        var previousLineWasBlank = false

        for line in lines {
            if line.isEmpty {
                if !previousLineWasBlank, !normalizedLines.isEmpty {
                    normalizedLines.append("")
                }
                previousLineWasBlank = true
            } else {
                normalizedLines.append(line)
                previousLineWasBlank = false
            }
        }

        while normalizedLines.last?.isEmpty == true {
            normalizedLines.removeLast()
        }

        return normalizedLines.joined(separator: "\n")
    }
}
