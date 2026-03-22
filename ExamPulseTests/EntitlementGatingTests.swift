import Testing
import Foundation
import SwiftData
@testable import ExamPulse

struct EntitlementGatingTests {

    // MARK: - Flashcard truncation

    @Test @MainActor func freeUserFlashcardsTruncatedToLimit() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "Bio", examDate: Date().addingTimeInterval(86400 * 14))
        context.insert(exam)

        let doc = StudyDocument(examId: exam.id, fileName: "notes.pdf", rawText: "Cell biology content")
        doc.exam = exam
        context.insert(doc)

        let mockGenerator = MockStudyContentGenerator()
        let manyFlashcards = (1...15).map { FlashcardDTO(front: "Q\($0)", back: "A\($0)") }
        mockGenerator.contentToReturn = StudyContent(
            summary: "Summary",
            topics: [
                StudyContent.GeneratedTopic(
                    title: "Cells",
                    flashcards: manyFlashcards,
                    questions: [QuizQuestionDTO(question: "What?", optionA: "A", optionB: "B", optionC: "C", optionD: "D", correctAnswer: "A", explanation: "")]
                )
            ]
        )

        let entitlements = MockEntitlementManager(isPro: false, maxFreeFlashcardsPerExam: 10)
        let vm = ExamDetailViewModel(
            generator: mockGenerator,
            apiKeyManager: MockAPIKeyManager(),
            entitlementManager: entitlements
        )

        await vm.generateStudyMaterials(for: exam, context: context)

        #expect(exam.flashcards.count == 10)
        #expect(exam.status == .ready)
    }

    @Test @MainActor func freeUserQuestionsTruncatedToLimit() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "Math", examDate: Date().addingTimeInterval(86400 * 7))
        context.insert(exam)

        let doc = StudyDocument(examId: exam.id, fileName: "calc.pdf", rawText: "Calculus content")
        doc.exam = exam
        context.insert(doc)

        let mockGenerator = MockStudyContentGenerator()
        let manyQuestions = (1...8).map {
            QuizQuestionDTO(question: "Q\($0)?", optionA: "A", optionB: "B", optionC: "C", optionD: "D", correctAnswer: "A", explanation: "")
        }
        mockGenerator.contentToReturn = StudyContent(
            summary: "Summary",
            topics: [
                StudyContent.GeneratedTopic(
                    title: "Derivatives",
                    flashcards: [FlashcardDTO(front: "F", back: "B")],
                    questions: manyQuestions
                )
            ]
        )

        let entitlements = MockEntitlementManager(isPro: false, maxFreeQuestionsPerExam: 5)
        let vm = ExamDetailViewModel(
            generator: mockGenerator,
            apiKeyManager: MockAPIKeyManager(),
            entitlementManager: entitlements
        )

        await vm.generateStudyMaterials(for: exam, context: context)

        #expect(exam.questions.count == 5)
    }

    @Test @MainActor func proUserKeepsAllContent() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "History", examDate: Date().addingTimeInterval(86400 * 14))
        context.insert(exam)

        let doc = StudyDocument(examId: exam.id, fileName: "history.pdf", rawText: "World War II overview")
        doc.exam = exam
        context.insert(doc)

        let mockGenerator = MockStudyContentGenerator()
        let manyFlashcards = (1...20).map { FlashcardDTO(front: "Q\($0)", back: "A\($0)") }
        let manyQuestions = (1...12).map {
            QuizQuestionDTO(question: "Q\($0)?", optionA: "A", optionB: "B", optionC: "C", optionD: "D", correctAnswer: "A", explanation: "")
        }
        mockGenerator.contentToReturn = StudyContent(
            summary: "Summary",
            topics: [
                StudyContent.GeneratedTopic(
                    title: "WWII",
                    flashcards: manyFlashcards,
                    questions: manyQuestions
                )
            ]
        )

        let entitlements = MockEntitlementManager(isPro: true)
        let vm = ExamDetailViewModel(
            generator: mockGenerator,
            apiKeyManager: MockAPIKeyManager(),
            entitlementManager: entitlements
        )

        await vm.generateStudyMaterials(for: exam, context: context)

        #expect(exam.flashcards.count == 20)
        #expect(exam.questions.count == 12)
    }

    // MARK: - Exam creation gating

    @Test func freeUserExamLimitReached() {
        let entitlements = MockEntitlementManager(isPro: false, maxFreeExams: 1)
        let currentExamCount = 1

        let canCreate = entitlements.isPro || currentExamCount < entitlements.maxFreeExams
        #expect(canCreate == false)
    }

    @Test func freeUserCanCreateFirstExam() {
        let entitlements = MockEntitlementManager(isPro: false, maxFreeExams: 1)
        let currentExamCount = 0

        let canCreate = entitlements.isPro || currentExamCount < entitlements.maxFreeExams
        #expect(canCreate == true)
    }

    @Test func proUserCanAlwaysCreateExam() {
        let entitlements = MockEntitlementManager(isPro: true, maxFreeExams: 1)
        let currentExamCount = 10

        let canCreate = entitlements.isPro || currentExamCount < entitlements.maxFreeExams
        #expect(canCreate == true)
    }

    // MARK: - EntitlementManager defaults

    @Test func entitlementManagerDefaultLimits() {
        let manager = MockEntitlementManager(isPro: false)
        #expect(manager.maxFreeExams == 1)
        #expect(manager.maxFreeFlashcardsPerExam == 10)
        #expect(manager.maxFreeQuestionsPerExam == 5)
    }

    @Test func setProStatusUpdatesFlag() {
        let manager = MockEntitlementManager(isPro: false)
        #expect(manager.isPro == false)

        manager.setProStatus(true)
        #expect(manager.isPro == true)
        #expect(manager.setProStatusCalled == true)
    }
}
