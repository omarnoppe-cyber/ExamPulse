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

        let combinedText = exam.studyDocuments
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

            for document in exam.studyDocuments {
                document.summary = summaryText
            }

            var createdTopics: [Topic] = []
            for (index, dto) in topicDTOs.enumerated() {
                let topic = Topic(
                    examId: exam.id,
                    title: dto.title,
                    masteryScore: 0,
                    sortOrder: index
                )
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
                    let card = Flashcard(
                        examId: exam.id,
                        topicId: topic.id,
                        front: dto.front,
                        back: dto.back
                    )
                    card.exam = exam
                    card.topic = topic
                    context.insert(card)
                }

                for dto in quizDTOs {
                    let q = Question(
                        examId: exam.id,
                        topicId: topic.id,
                        prompt: dto.question,
                        options: [dto.optionA, dto.optionB, dto.optionC, dto.optionD],
                        correctAnswer: dto.correctAnswer,
                        explanation: "",
                        type: "multipleChoice"
                    )
                    q.exam = exam
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
