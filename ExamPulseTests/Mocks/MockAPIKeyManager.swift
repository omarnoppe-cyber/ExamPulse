import Foundation
@testable import ExamPulse

final class MockAPIKeyManager: APIKeyManaging {
    var apiKey: String?

    var hasAPIKey: Bool {
        guard let key = apiKey else { return false }
        return !key.isEmpty
    }

    init(apiKey: String? = "test-api-key") {
        self.apiKey = apiKey
    }
}
