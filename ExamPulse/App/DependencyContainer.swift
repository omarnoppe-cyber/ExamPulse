import Foundation
import SwiftUI

private func defaultDocumentParser(for url: URL) -> DocumentParsingService {
    DocumentParserFactory.parser(for: url)
}

@Observable
final class DependencyContainer {
    let aiService: AIService
    let notificationService: NotificationServiceProtocol
    let fileStorageService: FileStorageServiceProtocol
    let apiKeyManager: APIKeyManaging
    let documentParserFactory: (URL) -> DocumentParsingService
    let studyContentGenerator: StudyContentGenerating
    let entitlementManager: EntitlementManaging
    let storeService: StoreServicing

    init(
        aiService: AIService? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        fileStorageService: FileStorageServiceProtocol? = nil,
        apiKeyManager: APIKeyManaging? = nil,
        documentParserFactory: ((URL) -> DocumentParsingService)? = nil,
        studyContentGenerator: StudyContentGenerating? = nil,
        entitlementManager: EntitlementManaging? = nil,
        storeService: StoreServicing? = nil
    ) {
        let keyManager = apiKeyManager ?? APIKeyManager()
        let ai = aiService ?? OpenAIService(apiKeyManager: keyManager)
        let parserFactory = documentParserFactory ?? defaultDocumentParser
        let entitlements = entitlementManager ?? EntitlementManager()

        self.apiKeyManager = keyManager
        self.aiService = ai
        self.notificationService = notificationService ?? NotificationService()
        self.fileStorageService = fileStorageService ?? FileStorageService()
        self.documentParserFactory = parserFactory
        self.studyContentGenerator = studyContentGenerator ?? StudyContentGenerator(
            aiService: ai,
            parserFactory: parserFactory
        )
        self.entitlementManager = entitlements
        self.storeService = storeService ?? StoreService(entitlementManager: entitlements)
    }
}

struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer()
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
