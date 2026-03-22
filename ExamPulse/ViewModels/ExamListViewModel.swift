import Foundation
import SwiftData
import Observation

@Observable
final class ExamListViewModel {
    var showingNewExam = false

    private let notificationService: NotificationServiceProtocol
    private let fileStorageService: FileStorageServiceProtocol

    init(
        notificationService: NotificationServiceProtocol,
        fileStorageService: FileStorageServiceProtocol
    ) {
        self.notificationService = notificationService
        self.fileStorageService = fileStorageService
    }

    func deleteExam(_ exam: Exam, context: ModelContext) {
        notificationService.cancelReminders(for: exam)
        fileStorageService.deleteFiles(for: exam.id)
        context.delete(exam)
    }
}
