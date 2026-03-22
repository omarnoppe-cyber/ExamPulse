import Foundation

struct DOCXParsingService: DocumentParsingService {
    func extractText(from fileURL: URL) async throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw DocumentParsingError.fileNotFound
        }

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        try ZIPExtractor.extract(zipURL: fileURL, to: tempDir)

        let documentXML = tempDir.appendingPathComponent("word/document.xml")
        guard FileManager.default.fileExists(atPath: documentXML.path) else {
            throw DocumentParsingError.parsingFailed("DOCX archive missing word/document.xml")
        }

        let data = try Data(contentsOf: documentXML)
        let parser = WordXMLParser(data: data, textTag: "w:t")
        let text = parser.parse()

        guard !text.isEmpty else {
            throw DocumentParsingError.parsingFailed("DOCX contains no extractable text.")
        }

        return text
    }
}

// MARK: - XML text extraction

final class WordXMLParser: NSObject, XMLParserDelegate {
    private let xmlParser: XMLParser
    private let textTag: String
    private var extractedText = ""
    private var currentText = ""
    private var isInsideTextTag = false

    init(data: Data, textTag: String) {
        self.xmlParser = XMLParser(data: data)
        self.textTag = textTag
        super.init()
        self.xmlParser.delegate = self
    }

    func parse() -> String {
        xmlParser.parse()
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?,
                attributes: [String: String] = [:]) {
        if elementName == textTag {
            isInsideTextTag = true
            currentText = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInsideTextTag {
            currentText += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName: String?) {
        if elementName == textTag {
            isInsideTextTag = false
            extractedText += currentText
        } else if elementName == "w:p" {
            extractedText += "\n"
        }
    }
}

