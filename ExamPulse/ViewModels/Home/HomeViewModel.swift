import Foundation
import Observation

@Observable
final class HomeViewModel {
    func greeting(for date: Date = .now) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }

    func nextExam(from exams: [Exam]) -> Exam? {
        let now = Date()
        return exams
            .filter { $0.examDate >= now }
            .min(by: { $0.examDate < $1.examDate })
    }

    func dueFlashcardCount(for exam: Exam) -> Int {
        exam.flashcards.filter(\.isDue).count
    }

    func nextReminderDescription(for exam: Exam) -> String {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0

        guard let nineAM = calendar.date(from: components) else {
            return "Tomorrow at 9:00 AM"
        }

        if nineAM > Date() {
            return "Today at 9:00 AM"
        }

        return "Tomorrow at 9:00 AM"
    }

    func countdownComponents(for exam: Exam) -> (days: Int, hours: Int) {
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour], from: now, to: exam.examDate)
        return (days: max(components.day ?? 0, 0), hours: max(components.hour ?? 0, 0))
    }
}
