import Foundation

struct PPTXParsingService: DocumentParsingService {
    func extractText(from fileURL: URL) async throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw DocumentParsingError.fileNotFound
        }

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        try ZIPExtractor.extract(zipURL: fileURL, to: tempDir)

        let slidesDir = tempDir.appendingPathComponent("ppt/slides")
        guard FileManager.default.fileExists(atPath: slidesDir.path) else {
            throw DocumentParsingError.parsingFailed("PPTX archive missing ppt/slides directory.")
        }

        let slideFiles = try FileManager.default
            .contentsOfDirectory(at: slidesDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "xml" && $0.lastPathComponent.hasPrefix("slide") }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }

        var fullText = ""
        for slideFile in slideFiles {
            let data = try Data(contentsOf: slideFile)
            let parser = OfficeXMLTextParser(data: data, textTag: "a:t", paragraphTag: "a:p")
            let slideText = parser.parse()
            if !slideText.isEmpty {
                fullText += slideText + "\n\n"
            }
        }

        let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw DocumentParsingError.parsingFailed("PPTX contains no extractable text.")
        }

        return trimmed
    }
}
