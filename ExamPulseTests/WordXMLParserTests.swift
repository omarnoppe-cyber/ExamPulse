import Testing
import Foundation
@testable import ExamPulse

struct WordXMLParserTests {
    @Test func parsesWordTextTags() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:r><w:t>Hello </w:t></w:r>
              <w:r><w:t>World</w:t></w:r>
            </w:p>
            <w:p>
              <w:r><w:t>Second paragraph</w:t></w:r>
            </w:p>
          </w:body>
        </w:document>
        """
        let data = xml.data(using: .utf8)!
        let parser = WordXMLParser(data: data, textTag: "w:t")
        let result = parser.parse()

        #expect(result.contains("Hello"))
        #expect(result.contains("World"))
        #expect(result.contains("Second paragraph"))
    }

    @Test func parsesPowerPointTextTags() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
               xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
          <p:cSld>
            <p:spTree>
              <p:sp>
                <p:txBody>
                  <a:p><a:r><a:t>Slide Title</a:t></a:r></a:p>
                  <a:p><a:r><a:t>Bullet point one</a:t></a:r></a:p>
                </p:txBody>
              </p:sp>
            </p:spTree>
          </p:cSld>
        </p:sld>
        """
        let data = xml.data(using: .utf8)!
        let parser = WordXMLParser(data: data, textTag: "a:t")
        let result = parser.parse()

        #expect(result.contains("Slide Title"))
        #expect(result.contains("Bullet point one"))
    }

    @Test func emptyDocumentReturnsEmptyString() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body></w:body>
        </w:document>
        """
        let data = xml.data(using: .utf8)!
        let parser = WordXMLParser(data: data, textTag: "w:t")
        let result = parser.parse()
        #expect(result.isEmpty)
    }

    @Test func handlesMultipleRunsInParagraph() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:r><w:t>Part</w:t></w:r>
              <w:r><w:t> one</w:t></w:r>
              <w:r><w:t> two</w:t></w:r>
            </w:p>
          </w:body>
        </w:document>
        """
        let data = xml.data(using: .utf8)!
        let parser = WordXMLParser(data: data, textTag: "w:t")
        let result = parser.parse()
        #expect(result.contains("Part one two"))
    }
}
