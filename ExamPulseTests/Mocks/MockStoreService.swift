import Foundation
import StoreKit
@testable import ExamPulse

final class MockStoreService: StoreServicing {
    var product: Product?
    var purchaseState: PurchaseState = .idle
    var purchaseCalled = false
    var restoreCalled = false

    func loadProduct() async {}

    func purchase() async throws {
        purchaseCalled = true
        purchaseState = .purchased
    }

    func restorePurchases() async {
        restoreCalled = true
    }
}
