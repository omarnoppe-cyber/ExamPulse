import Foundation
import Observation

@Observable
final class ExamSetupViewModel {
    var examTitle = ""
    var examDate = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: .now) ?? .now

    var canContinue: Bool {
        !examTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
