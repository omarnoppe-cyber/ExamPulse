import Foundation

enum DOCXTextExtractor {
    static func extractText(from url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentParsingError.fileNotFound
        }

        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        try ZIPExtractor.extract(zipURL: url, to: tempDirectory)

        let documentXML = tempDirectory.appendingPathComponent("word/document.xml")
        guard FileManager.default.fileExists(atPath: documentXML.path) else {
            throw DocumentParsingError.parsingFailed("DOCX archive missing word/document.xml")
        }

        let data = try Data(contentsOf: documentXML)
        let parser = OfficeXMLTextParser(data: data, textTag: "w:t", paragraphTag: "w:p")
        let text = parser.parse()

        guard !text.isEmpty else {
            throw DocumentParsingError.parsingFailed("DOCX contains no extractable text.")
        }

        return text
    }
}

final class OfficeXMLTextParser: NSObject, XMLParserDelegate {
    private let xmlParser: XMLParser
    private let textTag: String
    private let paragraphTag: String
    private var extractedText = ""
    private var currentText = ""
    private var isInsideTextTag = false

    init(data: Data, textTag: String, paragraphTag: String) {
        self.xmlParser = XMLParser(data: data)
        self.textTag = textTag
        self.paragraphTag = paragraphTag
        super.init()
        self.xmlParser.delegate = self
    }

    func parse() -> String {
        xmlParser.parse()
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Foundation’s `XMLParser` reports local names (`p`, `t`) while tags are often written as `w:p` / `w:t`.
    private func matchesTag(_ elementName: String, qualifiedName: String?, tag: String) -> Bool {
        let full = qualifiedName ?? elementName
        if full == tag { return true }
        if let local = tag.split(separator: ":").last, elementName == String(local) { return true }
        return false
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        if matchesTag(elementName, qualifiedName: qName, tag: textTag) {
            isInsideTextTag = true
            currentText = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInsideTextTag {
            currentText += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if matchesTag(elementName, qualifiedName: qName, tag: textTag) {
            isInsideTextTag = false
            extractedText += currentText
        } else if matchesTag(elementName, qualifiedName: qName, tag: paragraphTag) {
            extractedText += "\n"
        }
    }
}
