import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleDailyReminder(examDate: Date)
    func scheduleDailyReminders(for exam: Exam)
    func cancelReminders(for exam: Exam)
}

final class NotificationService: NotificationServiceProtocol {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleDailyReminder(examDate: Date) {
        cancelGenericDailyReminders()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let examDay = calendar.startOfDay(for: examDate)

        guard today <= examDay else { return }

        var currentDay = today
        var dayIndex = 0

        while currentDay <= examDay {
            let reminderDate = calendar.date(
                bySettingHour: 9,
                minute: 0,
                second: 0,
                of: currentDay
            ) ?? currentDay

            if reminderDate > Date() {
                let content = UNMutableNotificationContent()
                content.title = "ExamPulse"
                content.body = "Ready for 5 flashcards?"
                content.sound = .default

                let dateComponents = calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: reminderDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(
                    identifier: genericNotificationID(for: dayIndex),
                    content: content,
                    trigger: trigger
                )

                center.add(request)
            }

            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
            dayIndex += 1
        }
    }

    func scheduleDailyReminders(for exam: Exam) {
        cancelReminders(for: exam)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let examDay = calendar.startOfDay(for: exam.examDate)

        var currentDay = today
        var dayIndex = 0

        while currentDay <= examDay {
            let daysLeft = calendar.dateComponents([.day], from: currentDay, to: examDay).day ?? 0
            let content = UNMutableNotificationContent()
            content.title = "ExamPulse"
            content.sound = .default

            if daysLeft == 0 {
                content.body = "Today is exam day for \"\(exam.title)\"! You've got this!"
            } else if daysLeft == 1 {
                content.body = "Tomorrow is your \"\(exam.title)\" exam. Final review time!"
            } else {
                content.body = "\(daysLeft) days until \"\(exam.title)\". Time to study!"
            }

            var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDay)
            dateComponents.hour = 9
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = notificationID(for: exam, day: dayIndex)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            center.add(request)

            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
            dayIndex += 1
        }
    }

    func cancelReminders(for exam: Exam) {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let prefix = self.notificationPrefix(for: exam)
            let idsToRemove = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    // MARK: - Private

    private func notificationPrefix(for exam: Exam) -> String {
        "exam-\(exam.id.uuidString)"
    }

    private func genericNotificationPrefix() -> String {
        "daily-study-reminder"
    }

    private func notificationID(for exam: Exam, day: Int) -> String {
        "\(notificationPrefix(for: exam))-day\(day)"
    }

    private func genericNotificationID(for day: Int) -> String {
        "\(genericNotificationPrefix())-day\(day)"
    }

    private func cancelGenericDailyReminders() {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let prefix = self.genericNotificationPrefix()
            let idsToRemove = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }
}
