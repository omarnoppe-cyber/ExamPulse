import Testing
import Foundation
import SwiftData
@testable import ExamPulse

struct DocumentImportViewModelTests {
    private func makeVM(
        fileStorage: MockFileStorageService = MockFileStorageService(),
        notification: MockNotificationService = MockNotificationService(),
        parser: MockDocumentParsingService = MockDocumentParsingService()
    ) -> (DocumentImportViewModel, MockFileStorageService, MockNotificationService) {
        let vm = DocumentImportViewModel(
            fileStorageService: fileStorage,
            notificationService: notification,
            parserFactory: { _ in parser }
        )
        return (vm, fileStorage, notification)
    }

    @Test func canCreateRequiresTitleAndFiles() {
        let (vm, _, _) = makeVM()

        #expect(vm.canCreate == false)

        vm.title = "My Exam"
        #expect(vm.canCreate == false)

        vm.addFile(URL(fileURLWithPath: "/tmp/test.pdf"))
        #expect(vm.canCreate == true)
    }

    @Test func canCreateRejectsWhitespaceOnlyTitle() {
        let (vm, _, _) = makeVM()
        vm.title = "   "
        vm.addFile(URL(fileURLWithPath: "/tmp/test.pdf"))
        #expect(vm.canCreate == false)
    }

    @Test func addFilePreventsNameDuplicates() {
        let (vm, _, _) = makeVM()
        vm.addFile(URL(fileURLWithPath: "/tmp/a/test.pdf"))
        vm.addFile(URL(fileURLWithPath: "/tmp/b/test.pdf"))
        #expect(vm.importedFileURLs.count == 1)
    }

    @Test @MainActor func createExamReturnsNilWhenCannotCreate() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext
        let (vm, _, _) = makeVM()

        let result = await vm.createExam(context: context)
        #expect(result == nil)
    }

    @Test @MainActor func createExamSucceedsAndSchedulesNotifications() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let mockStorage = MockFileStorageService()
        let mockNotification = MockNotificationService()
        let mockParser = MockDocumentParsingService(textToReturn: "Some study text")

        let (vm, _, _) = makeVM(
            fileStorage: mockStorage,
            notification: mockNotification,
            parser: mockParser
        )

        vm.title = "Calc Exam"
        vm.addFile(URL(fileURLWithPath: "/tmp/calc.pdf"))

        let exam = await vm.createExam(context: context)

        #expect(exam != nil)
        #expect(exam?.title == "Calc Exam")
        #expect(exam?.status == .new)
        #expect(mockStorage.persistedFiles.count == 1)
        #expect(mockNotification.scheduledExams.count == 1)
        #expect(vm.isParsing == false)
    }

    @Test @MainActor func createExamHandlesStorageError() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let mockStorage = MockFileStorageService()
        mockStorage.errorToThrow = DocumentParsingError.fileNotFound

        let (vm, _, _) = makeVM(fileStorage: mockStorage)
        vm.title = "Fail Exam"
        vm.addFile(URL(fileURLWithPath: "/tmp/fail.pdf"))

        let exam = await vm.createExam(context: context)

        #expect(exam?.status == .error)
        #expect(vm.errorMessage != nil)
        #expect(vm.isParsing == false)
    }
}
