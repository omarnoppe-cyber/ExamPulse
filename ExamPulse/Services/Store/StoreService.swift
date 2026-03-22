import Foundation
import StoreKit
import Observation

enum PurchaseState: Equatable {
    case idle
    case purchasing
    case purchased
    case failed(String)

    static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.purchasing, .purchasing), (.purchased, .purchased):
            return true
        case (.failed(let a), .failed(let b)):
            return a == b
        default:
            return false
        }
    }
}

protocol StoreServicing: AnyObject {
    var product: Product? { get }
    var purchaseState: PurchaseState { get }
    func loadProduct() async
    func purchase() async throws
    func restorePurchases() async
}

@Observable
final class StoreService: StoreServicing {
    static let productID = "com.exampulse.pro"

    var product: Product?
    var purchaseState: PurchaseState = .idle

    private let entitlementManager: EntitlementManaging
    private var updateListenerTask: Task<Void, Never>?

    init(entitlementManager: EntitlementManaging) {
        self.entitlementManager = entitlementManager
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            product = nil
        }

        await checkCurrentEntitlements()
    }

    func purchase() async throws {
        guard let product else { return }

        purchaseState = .purchasing

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                entitlementManager.setProStatus(true)
                purchaseState = .purchased

            case .userCancelled:
                purchaseState = .idle

            case .pending:
                purchaseState = .idle

            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            throw error
        }
    }

    func restorePurchases() async {
        await checkCurrentEntitlements()
    }

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let transaction = try? await self.checkVerified(result) {
                    await self.entitlementManager.setProStatus(true)
                    await transaction.finish()
                }
            }
        }
    }

    private func checkCurrentEntitlements() async {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.productID {
                hasPro = true
            }
        }

        entitlementManager.setProStatus(hasPro)
        if hasPro {
            purchaseState = .purchased
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed."
        }
    }
}
