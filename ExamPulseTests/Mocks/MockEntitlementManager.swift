import Foundation
@testable import ExamPulse

final class MockEntitlementManager: EntitlementManaging {
    var isPro: Bool
    var maxFreeExams: Int
    var maxFreeFlashcardsPerExam: Int
    var maxFreeQuestionsPerExam: Int
    var setProStatusCalled = false

    init(
        isPro: Bool = true,
        maxFreeExams: Int = 1,
        maxFreeFlashcardsPerExam: Int = 10,
        maxFreeQuestionsPerExam: Int = 5
    ) {
        self.isPro = isPro
        self.maxFreeExams = maxFreeExams
        self.maxFreeFlashcardsPerExam = maxFreeFlashcardsPerExam
        self.maxFreeQuestionsPerExam = maxFreeQuestionsPerExam
    }

    func setProStatus(_ isPro: Bool) {
        self.isPro = isPro
        setProStatusCalled = true
    }
}
