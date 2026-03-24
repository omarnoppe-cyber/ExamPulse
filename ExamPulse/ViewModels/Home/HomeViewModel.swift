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

}
