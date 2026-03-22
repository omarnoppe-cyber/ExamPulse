import Foundation
@testable import ExamPulse

final class MockNotificationService: NotificationServiceProtocol {
    var authorizationResult = true
    var genericScheduledExamDates: [Date] = []
    var scheduledExams: [UUID] = []
    var cancelledExams: [UUID] = []

    func requestAuthorization() async throws -> Bool {
        authorizationResult
    }

    func scheduleDailyReminder(examDate: Date) {
        genericScheduledExamDates.append(examDate)
    }

    func scheduleDailyReminders(for exam: Exam) {
        scheduledExams.append(exam.id)
    }

    func cancelReminders(for exam: Exam) {
        cancelledExams.append(exam.id)
    }
}
