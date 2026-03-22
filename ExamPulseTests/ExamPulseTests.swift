import Testing
import Foundation
@testable import ExamPulse

struct DependencyContainerTests {
    @Test func containerAcceptsInjectedDependencies() {
        let mockAI = MockAIService()
        let mockNotification = MockNotificationService()
        let mockStorage = MockFileStorageService()
        let mockKeyManager = MockAPIKeyManager(apiKey: "injected")

        let container = DependencyContainer(
            aiService: mockAI,
            notificationService: mockNotification,
            fileStorageService: mockStorage,
            apiKeyManager: mockKeyManager
        )

        #expect(container.aiService is MockAIService)
        #expect(container.notificationService is MockNotificationService)
        #expect(container.fileStorageService is MockFileStorageService)
        #expect((container.apiKeyManager as? MockAPIKeyManager)?.apiKey == "injected")
    }
}
