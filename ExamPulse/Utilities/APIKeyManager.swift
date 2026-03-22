import Foundation
import Security

protocol APIKeyManaging: AnyObject {
    var apiKey: String? { get set }
    var hasAPIKey: Bool { get }
}

final class APIKeyManager: APIKeyManaging {
    private let service: String
    private let account: String

    init(service: String = "com.exampulse.openai-api-key", account: String = "openai") {
        self.service = service
        self.account = account
    }

    var apiKey: String? {
        get { readFromKeychain() }
        set {
            if let newValue {
                saveToKeychain(newValue)
            } else {
                deleteFromKeychain()
            }
        }
    }

    var hasAPIKey: Bool {
        guard let key = apiKey else { return false }
        return !key.isEmpty
    }

    // MARK: - Keychain

    private func saveToKeychain(_ value: String) {
        deleteFromKeychain()

        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func readFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
