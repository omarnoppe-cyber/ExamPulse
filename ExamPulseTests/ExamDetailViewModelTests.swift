import Testing
import Foundation
import SwiftData
@testable import ExamPulse

struct ExamDetailViewModelTests {
    @Test @MainActor func generateStudyMaterialsSucceeds() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "Bio Exam", examDate: Date().addingTimeInterval(86400 * 14))
        context.insert(exam)

        let doc = Document(filename: "notes.pdf", fileURL: "/tmp/notes.pdf", rawText: "Cell biology covers organelles, DNA replication, and protein synthesis.")
        doc.exam = exam
        context.insert(doc)

        let mockAI = MockAIService()
        let mockKeyManager = MockAPIKeyManager(apiKey: "sk-test")
        let vm = ExamDetailViewModel(aiService: mockAI, apiKeyManager: mockKeyManager)

        await vm.generateStudyMaterials(for: exam, context: context)

        #expect(mockAI.generateSummaryCalled == true)
        #expect(mockAI.generateTopicsCalled == true)
        #expect(mockAI.generateFlashcardsCalled == true)
        #expect(mockAI.generateQuizQuestionsCalled == true)
        #expect(exam.status == .ready)
        #expect(vm.isGenerating == false)
        #expect(vm.errorMessage == nil)
    }

    @Test @MainActor func generateStudyMaterialsSetsErrorOnFailure() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "Fail Exam", examDate: Date().addingTimeInterval(86400 * 14))
        context.insert(exam)

        let doc = Document(filename: "notes.pdf", fileURL: "/tmp/notes.pdf", rawText: "Some content")
        doc.exam = exam
        context.insert(doc)

        let mockAI = MockAIService()
        mockAI.errorToThrow = AIServiceError.requestFailed("Network error")

        let vm = ExamDetailViewModel(
            aiService: mockAI,
            apiKeyManager: MockAPIKeyManager()
        )

        await vm.generateStudyMaterials(for: exam, context: context)

        #expect(exam.status == .error)
        #expect(vm.errorMessage != nil)
        #expect(vm.isGenerating == false)
    }

    @Test @MainActor func generateWithEmptyDocumentsShowsError() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "Empty Exam", examDate: Date().addingTimeInterval(86400 * 7))
        context.insert(exam)

        let vm = ExamDetailViewModel(
            aiService: MockAIService(),
            apiKeyManager: MockAPIKeyManager()
        )

        await vm.generateStudyMaterials(for: exam, context: context)

        #expect(vm.errorMessage == "No text extracted from documents.")
        #expect(vm.isGenerating == false)
    }

    @Test @MainActor func doesNotDoubleGenerate() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "Double Exam", examDate: Date().addingTimeInterval(86400 * 7))
        context.insert(exam)

        let doc = Document(filename: "notes.pdf", fileURL: "/tmp/notes.pdf", rawText: "Content")
        doc.exam = exam
        context.insert(doc)

        let mockAI = MockAIService()
        let vm = ExamDetailViewModel(
            aiService: mockAI,
            apiKeyManager: MockAPIKeyManager()
        )

        vm.isGenerating = true
        await vm.generateStudyMaterials(for: exam, context: context)

        #expect(mockAI.generateSummaryCalled == false)
    }
}
