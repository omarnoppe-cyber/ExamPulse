import Foundation

struct StudyContent {
    let summary: String
    let topics: [GeneratedTopic]

    struct GeneratedTopic {
        let title: String
        let flashcards: [FlashcardDTO]
        let questions: [QuizQuestionDTO]
    }
}

protocol StudyContentGenerating {
    func generate(from fileURLs: [URL]) async throws -> StudyContent
    func generateFromText(_ text: String) async throws -> StudyContent
}

final class StudyContentGenerator: StudyContentGenerating {
    private let aiService: AIService
    private let parserFactory: (URL) -> DocumentParsingService

    init(aiService: AIService, parserFactory: @escaping (URL) -> DocumentParsingService) {
        self.aiService = aiService
        self.parserFactory = parserFactory
    }

    func generate(from fileURLs: [URL]) async throws -> StudyContent {
        let rawText = try await extractText(from: fileURLs)
        return try await generateFromText(rawText)
    }

    func generateFromText(_ text: String) async throws -> StudyContent {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StudyContentError.noTextExtracted
        }

        let chunks = TextChunker.chunk(text: text)

        let summary = try await summarizeChunks(chunks)

        let topicDTOs = try await aiService.generateTopics(from: summary)
        guard !topicDTOs.isEmpty else {
            throw StudyContentError.noTopicsGenerated
        }

        let topics = try await generateTopicContent(topicDTOs, context: text)

        return StudyContent(summary: summary, topics: topics)
    }

    private func extractText(from fileURLs: [URL]) async throws -> String {
        var texts: [String] = []

        for url in fileURLs {
            let parser = parserFactory(url)
            let text = try await parser.extractText(from: url)
            texts.append(text)
        }

        return texts.joined(separator: "\n\n")
    }

    private func summarizeChunks(_ chunks: [String]) async throws -> String {
        if chunks.count <= 1 {
            let text = chunks.first ?? ""
            return try await aiService.generateSummary(from: text)
        }

        let chunkSummaries = try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for (index, chunk) in chunks.enumerated() {
                group.addTask { [aiService] in
                    let summary = try await aiService.generateSummary(from: chunk)
                    return (index, summary)
                }
            }

            var results = [(Int, String)]()
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map(\.1)
        }

        let merged = chunkSummaries.joined(separator: "\n\n")
        return try await aiService.generateSummary(from: merged)
    }

    private func generateTopicContent(
        _ topicDTOs: [TopicDTO],
        context: String
    ) async throws -> [StudyContent.GeneratedTopic] {
        try await withThrowingTaskGroup(of: (Int, StudyContent.GeneratedTopic).self) { group in
            for (index, dto) in topicDTOs.enumerated() {
                group.addTask { [aiService] in
                    async let flashcardsTask = aiService.generateFlashcards(for: dto.title, context: context)
                    async let questionsTask = aiService.generateQuizQuestions(for: dto.title, context: context)

                    let (flashcards, questions) = try await (flashcardsTask, questionsTask)

                    let topic = StudyContent.GeneratedTopic(
                        title: dto.title,
                        flashcards: flashcards,
                        questions: questions
                    )
                    return (index, topic)
                }
            }

            var results = [(Int, StudyContent.GeneratedTopic)]()
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map(\.1)
        }
    }
}

enum StudyContentError: LocalizedError {
    case noTextExtracted
    case noTopicsGenerated

    var errorDescription: String? {
        switch self {
        case .noTextExtracted:
            return "No text extracted from documents."
        case .noTopicsGenerated:
            return "AI did not generate any topics from the study material."
        }
    }
}
