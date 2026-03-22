import Foundation
import Observation

protocol EntitlementManaging: AnyObject {
    var isPro: Bool { get }
    var maxFreeExams: Int { get }
    var maxFreeFlashcardsPerExam: Int { get }
    var maxFreeQuestionsPerExam: Int { get }
    func setProStatus(_ isPro: Bool)
}

@Observable
final class EntitlementManager: EntitlementManaging {
    private static let isProKey = "com.exampulse.isPro"

    var isPro: Bool {
        didSet { UserDefaults.standard.set(isPro, forKey: Self.isProKey) }
    }

    let maxFreeExams = 1
    let maxFreeFlashcardsPerExam = 10
    let maxFreeQuestionsPerExam = 5

    init() {
        self.isPro = UserDefaults.standard.bool(forKey: Self.isProKey)
    }

    func setProStatus(_ isPro: Bool) {
        self.isPro = isPro
    }
}
