import Foundation
import SwiftData
import Observation

@Observable
final class ExamDetailViewModel {
    var isGenerating = false
    var errorMessage: String?

    private let generator: StudyContentGenerating
    let apiKeyManager: APIKeyManaging

    init(generator: StudyContentGenerating, apiKeyManager: APIKeyManaging) {
        self.generator = generator
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
            let content = try await generator.generateFromText(combinedText)
            applyContent(content, to: exam, context: context)
            exam.status = .ready
        } catch {
            exam.status = .error
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }

    @MainActor
    private func applyContent(_ content: StudyContent, to exam: Exam, context: ModelContext) {
        for document in exam.studyDocuments {
            document.summary = content.summary
        }

        for (index, generatedTopic) in content.topics.enumerated() {
            let topic = Topic(
                examId: exam.id,
                title: generatedTopic.title,
                masteryScore: 0,
                sortOrder: index
            )
            topic.exam = exam
            context.insert(topic)

            for dto in generatedTopic.flashcards {
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

            for dto in generatedTopic.questions {
                let q = Question(
                    examId: exam.id,
                    topicId: topic.id,
                    prompt: dto.question,
                    options: [dto.optionA, dto.optionB, dto.optionC, dto.optionD],
                    correctAnswer: dto.correctAnswer,
                    explanation: dto.explanation ?? "",
                    type: "multipleChoice"
                )
                q.exam = exam
                q.topic = topic
                context.insert(q)
            }
        }
    }
}
