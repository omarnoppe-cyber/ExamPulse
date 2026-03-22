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

    init(
        aiService: AIService? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        fileStorageService: FileStorageServiceProtocol? = nil,
        apiKeyManager: APIKeyManaging? = nil,
        documentParserFactory: ((URL) -> DocumentParsingService)? = nil
    ) {
        let keyManager = apiKeyManager ?? APIKeyManager()
        self.apiKeyManager = keyManager
        self.aiService = aiService ?? OpenAIService(apiKeyManager: keyManager)
        self.notificationService = notificationService ?? NotificationService()
        self.fileStorageService = fileStorageService ?? FileStorageService()
        self.documentParserFactory = documentParserFactory ?? defaultDocumentParser
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
