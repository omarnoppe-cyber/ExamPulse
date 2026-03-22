import Foundation
import NaturalLanguage

func chunk(text: String) -> [String] {
    TextChunker.chunk(text: text)
}

enum TextChunker {
    private static let chunkSize = 1500
    private static let overlapSize = 150

    static func chunk(text: String) -> [String] {
        let normalizedText = normalizeWhitespace(in: text)
        guard !normalizedText.isEmpty else { return [] }

        let sentences = sentenceFragments(from: normalizedText)
        guard !sentences.isEmpty else {
            return chunkLongText(normalizedText)
        }

        var chunks: [String] = []
        var startIndex = 0

        while startIndex < sentences.count {
            if sentences[startIndex].wordCount > chunkSize {
                chunks.append(contentsOf: chunkLongText(sentences[startIndex].text))
                startIndex += 1
                continue
            }

            var endIndex = startIndex
            var currentWordCount = 0

            while endIndex < sentences.count {
                let nextSentenceWords = sentences[endIndex].wordCount
                if currentWordCount > 0 && currentWordCount + nextSentenceWords > chunkSize {
                    break
                }

                currentWordCount += nextSentenceWords
                endIndex += 1
            }

            if endIndex == startIndex {
                chunks.append(contentsOf: chunkLongText(sentences[startIndex].text))
                startIndex += 1
                continue
            }

            chunks.append(
                sentences[startIndex..<endIndex]
                    .map(\.text)
                    .joined(separator: " ")
            )

            if endIndex >= sentences.count {
                break
            }

            let nextStartIndex = overlapStartIndex(sentences: sentences, endIndex: endIndex)
            startIndex = nextStartIndex > startIndex ? nextStartIndex : endIndex
        }

        return chunks
    }

    private static func normalizeWhitespace(in text: String) -> String {
        text
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func sentenceFragments(from text: String) -> [SentenceFragment] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text

        var fragments: [SentenceFragment] = []
        let fullRange = text.startIndex..<text.endIndex

        tokenizer.enumerateTokens(in: fullRange) { range, _ in
            let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            let wordCount = countWords(in: sentence)

            if !sentence.isEmpty && wordCount > 0 {
                fragments.append(SentenceFragment(text: sentence, wordCount: wordCount))
            }

            return true
        }

        return fragments
    }

    private static func overlapStartIndex(sentences: [SentenceFragment], endIndex: Int) -> Int {
        var overlapWordCount = 0
        var index = endIndex - 1

        while index >= 0 {
            overlapWordCount += sentences[index].wordCount
            if overlapWordCount >= overlapSize {
                return index
            }
            index -= 1
        }

        return 0
    }

    private static func chunkLongText(_ text: String) -> [String] {
        let words = text.split(whereSeparator: \.isWhitespace).map(String.init)
        guard !words.isEmpty else { return [] }

        var chunks: [String] = []
        var start = 0

        while start < words.count {
            let end = min(start + chunkSize, words.count)
            chunks.append(words[start..<end].joined(separator: " "))

            if end == words.count {
                break
            }

            start = max(end - overlapSize, start + 1)
        }

        return chunks
    }

    private static func countWords(in text: String) -> Int {
        text.split(whereSeparator: \.isWhitespace).count
    }
}

private struct SentenceFragment {
    let text: String
    let wordCount: Int
}
