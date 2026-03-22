import Foundation
import SwiftData
import Observation

@Observable
final class ExamDetailViewModel {
    var isGenerating = false
    var errorMessage: String?

    private let aiService: AIService
    let apiKeyManager: APIKeyManaging

    init(aiService: AIService, apiKeyManager: APIKeyManaging) {
        self.aiService = aiService
        self.apiKeyManager = apiKeyManager
    }

    @MainActor
    func generateStudyMaterials(for exam: Exam, context: ModelContext) async {
        guard !isGenerating else { return }

        let combinedText = exam.documents
            .map(\.rawText)
            .joined(separator: "\n\n")

        guard !combinedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "No text extracted from documents."
            return
        }

        isGenerating = true
        errorMessage = nil
        exam.status = .generating

        do {
            async let summaryTask = aiService.generateSummary(from: combinedText)
            async let topicsTask = aiService.generateTopics(from: combinedText)

            let (summaryText, topicDTOs) = try await (summaryTask, topicsTask)

            let summary = Summary(content: summaryText)
            summary.exam = exam
            context.insert(summary)

            var createdTopics: [Topic] = []
            for (index, dto) in topicDTOs.enumerated() {
                let topic = Topic(title: dto.title, sortOrder: index)
                topic.exam = exam
                context.insert(topic)
                createdTopics.append(topic)
            }

            for topic in createdTopics {
                async let flashcardsTask = aiService.generateFlashcards(
                    for: topic.title, context: combinedText
                )
                async let quizTask = aiService.generateQuizQuestions(
                    for: topic.title, context: combinedText
                )

                let (flashcardDTOs, quizDTOs) = try await (flashcardsTask, quizTask)

                for dto in flashcardDTOs {
                    let card = Flashcard(front: dto.front, back: dto.back)
                    card.topic = topic
                    context.insert(card)
                }

                for dto in quizDTOs {
                    let q = QuizQuestion(
                        question: dto.question,
                        optionA: dto.optionA,
                        optionB: dto.optionB,
                        optionC: dto.optionC,
                        optionD: dto.optionD,
                        correctAnswer: dto.correctAnswer
                    )
                    q.topic = topic
                    context.insert(q)
                }
            }

            exam.status = .ready
        } catch {
            exam.status = .error
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }
}
