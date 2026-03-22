import Testing
@testable import ExamPulse

struct TextChunkerTests {
    @Test func emptyTextReturnsNoChunks() {
        #expect(chunk(text: "").isEmpty)
    }

    @Test func shortTextReturnsSingleChunk() {
        let text = "This is the first sentence. This is the second sentence."

        let chunks = chunk(text: text)

        #expect(chunks.count == 1)
        #expect(chunks[0] == text)
    }

    @Test func chunkingNormalizesExtraWhitespace() {
        let text = "First sentence.\n\n\nSecond\t\t sentence.   Third sentence."

        let chunks = chunk(text: text)

        #expect(chunks.count == 1)
        #expect(chunks[0] == "First sentence. Second sentence. Third sentence.")
    }

    @Test func largeTextUsesSentenceAwareBoundariesAndOverlap() {
        let sentences = (1...20).map { sentenceNumber in
            makeSentence(number: sentenceNumber, wordCount: 100)
        }
        let text = sentences.joined(separator: " ")

        let chunks = chunk(text: text)

        #expect(chunks.count == 2)
        #expect(chunks[0].contains(sentences[0]))
        #expect(chunks[0].contains(sentences[14]))
        #expect(chunks[1].hasPrefix("\(sentences[13]) \(sentences[14])"))
        #expect(chunks[1].contains(sentences[19]))
    }

    @Test func oversizedSentenceFallsBackToWordChunking() {
        let words = (1...1605).map { "word\($0)" }.joined(separator: " ")

        let chunks = chunk(text: words)

        #expect(chunks.count == 2)
        #expect(chunks[0].split(whereSeparator: \.isWhitespace).count == 1500)
        #expect(chunks[1].split(whereSeparator: \.isWhitespace).count == 255)
        #expect(chunks[1].hasPrefix("word1351"))
    }

    private func makeSentence(number: Int, wordCount: Int) -> String {
        let body = (1...wordCount).map { "s\(number)w\($0)" }.joined(separator: " ")
        return "\(body)."
    }
}
