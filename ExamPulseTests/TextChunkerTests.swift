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

        // NLTokenizer often treats this synthetic text as a single “sentence”, so chunking uses word overlap
        // (1500 words + overlap) instead of per-sentence fragments. Assert that invariant.
        #expect(chunks.count == 2)
        let words0 = chunks[0].split(whereSeparator: \.isWhitespace)
        let words1 = chunks[1].split(whereSeparator: \.isWhitespace)
        #expect(words0.count == 1500)
        #expect(words1.count == 650)
        #expect(Array(words0.suffix(150)) == Array(words1.prefix(150)))
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
