import Testing
import Foundation
@testable import ExamPulse

struct StudyContentGeneratorTests {
    @Test func generatesContentFromText() async throws {
        let mockAI = MockAIService()
        let generator = StudyContentGenerator(
            aiService: mockAI,
            parserFactory: { _ in MockDocumentParsingService() }
        )

        let content = try await generator.generateFromText("Cell biology covers organelles and mitosis.")

        #expect(mockAI.generateSummaryCalled == true)
        #expect(mockAI.generateTopicsCalled == true)
        #expect(mockAI.generateFlashcardsCalled == true)
        #expect(mockAI.generateQuizQuestionsCalled == true)
        #expect(!content.summary.isEmpty)
        #expect(!content.topics.isEmpty)
    }

    @Test func throwsOnEmptyText() async {
        let generator = StudyContentGenerator(
            aiService: MockAIService(),
            parserFactory: { _ in MockDocumentParsingService() }
        )

        do {
            _ = try await generator.generateFromText("   ")
            #expect(Bool(false), "Expected error")
        } catch {
            #expect(error is StudyContentError)
        }
    }

    @Test func generatesFromFileURLs() async throws {
        let mockParser = MockDocumentParsingService(textToReturn: "Study content about biology.")
        let mockAI = MockAIService()
        let generator = StudyContentGenerator(
            aiService: mockAI,
            parserFactory: { _ in mockParser }
        )

        let content = try await generator.generate(from: [URL(fileURLWithPath: "/tmp/test.pdf")])

        #expect(!content.summary.isEmpty)
        #expect(!content.topics.isEmpty)
    }

    @Test func preservesTopicOrder() async throws {
        let mockAI = MockAIService()
        mockAI.topicsToReturn = [
            TopicDTO(title: "First"),
            TopicDTO(title: "Second"),
            TopicDTO(title: "Third")
        ]

        let generator = StudyContentGenerator(
            aiService: mockAI,
            parserFactory: { _ in MockDocumentParsingService() }
        )

        let content = try await generator.generateFromText("Some study material.")

        #expect(content.topics.count == 3)
        #expect(content.topics[0].title == "First")
        #expect(content.topics[1].title == "Second")
        #expect(content.topics[2].title == "Third")
    }

    @Test func propagatesAIError() async {
        let mockAI = MockAIService()
        mockAI.errorToThrow = AIServiceError.requestFailed("Rate limited")

        let generator = StudyContentGenerator(
            aiService: mockAI,
            parserFactory: { _ in MockDocumentParsingService() }
        )

        do {
            _ = try await generator.generateFromText("Some content")
            #expect(Bool(false), "Expected error")
        } catch {
            #expect(error is AIServiceError)
        }
    }
}
