import Testing
import Foundation
import CoreGraphics
import UIKit
@testable import ExamPulse

struct DocumentTextExtractionTests {
    @Test func pdfParsingServiceExtractsCombinedCleanText() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")
        defer { try? FileManager.default.removeItem(at: url) }

        let pdfData = makePDFData(pages: [
            "Hello   PDF page one.",
            "Page two text.\n\nExtra spacing."
        ])
        try pdfData.write(to: url)

        let text = try await PDFParsingService().extractText(from: url)

        #expect(text == "Hello PDF page one.\n\nPage two text.\n\nExtra spacing.")
    }

    @Test func docxTextExtractorReadsWordDocumentXML() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("docx")
        defer { try? FileManager.default.removeItem(at: url) }

        let docxData = try #require(
            Data(base64Encoded: "UEsDBBQAAAAIALepdlwDdPGWqwAAAAEBAAARAAAAd29yZC9kb2N1bWVudC54bWxtjzELwjAQhff+ipDdpjqIlDYOirg5qOBak7MWkruQRKv/3qTi5vLxHnfvHdesX9awJ/gwELZ8XlacASrSA/YtP592sxVfy6IZa03qYQEjSwEM9djye4yuFiKoO9gulOQA0+xG3nYxWd+Lkbx2nhSEkPqsEYuqWgrbDchlwVhqvZJ+ZzkZJxN8RpR7MIbY9rC5NCL7TD/R/d0/giLUzAwIfwNZfI9l9XtGFh9QSwECFAMUAAAACAC3qXZcA3TxlqsAAAABAQAAEQAAAAAAAAAAAAAAgAEAAAAAd29yZC9kb2N1bWVudC54bWxQSwUGAAAAAAEAAQA/AAAA2gAAAAAA")
        )
        try docxData.write(to: url)

        let text = try DOCXTextExtractor.extractText(from: url)

        #expect(text == "Hello DOCX\nSecond line")
    }

    private func makePDFData(pages: [String]) -> Data {
        let bounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        return renderer.pdfData { context in
            for pageText in pages {
                context.beginPage()
                pageText.draw(
                    in: CGRect(x: 40, y: 40, width: 532, height: 712),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 16)
                    ]
                )
            }
        }
    }
}
