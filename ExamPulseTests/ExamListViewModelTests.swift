import Testing
import Foundation
import SwiftData
@testable import ExamPulse

struct ExamListViewModelTests {
    @Test @MainActor func deleteExamCancelsNotificationsAndDeletesFiles() async throws {
        let container = try TestModelContainer.create()
        let context = container.mainContext

        let exam = Exam(title: "Test Exam", examDate: Date().addingTimeInterval(86400 * 7))
        context.insert(exam)
        let examID = exam.id

        let mockNotification = MockNotificationService()
        let mockStorage = MockFileStorageService()
        let vm = ExamListViewModel(
            notificationService: mockNotification,
            fileStorageService: mockStorage
        )

        vm.deleteExam(exam, context: context)

        #expect(mockNotification.cancelledExams.contains(examID))
        #expect(mockStorage.deletedExamIDs.contains(examID))
    }
}
