import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)?

    private var storeService: StoreServicing { dependencies.storeService }
    private var entitlementManager: EntitlementManaging { dependencies.entitlementManager }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                heroHeader
                comparisonList
                purchaseButton
                restoreLink
            }
            .padding(24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Go Pro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if onDismiss != nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { onDismiss?() }
                }
            }
        }
        .onChange(of: storeService.purchaseState) { _, newState in
            if newState == .purchased {
                if let onDismiss { onDismiss() } else { dismiss() }
            }
        }
    }
}

// MARK: - Header

private extension PaywallView {
    var heroHeader: some View {
        GradientHero(
            systemImage: "sparkles.rectangle.stack.fill",
            title: "Unlock ExamPulse Pro",
            subtitle: "Get unlimited study tools and stay fully prepared for every exam.",
            gradient: [.blue, .purple]
        )
    }
}

// MARK: - Comparison

private extension PaywallView {
    var comparisonList: some View {
        VStack(spacing: 0) {
            comparisonRow(feature: "Exams", free: "1", pro: "Unlimited", systemImage: "calendar.badge.plus")
            thinDivider
            comparisonRow(feature: "Flashcards / exam", free: "10", pro: "Unlimited", systemImage: "rectangle.on.rectangle.angled")
            thinDivider
            comparisonRow(feature: "Questions / exam", free: "5", pro: "Unlimited", systemImage: "questionmark.circle")
            thinDivider
            comparisonRow(feature: "Exam reminders", free: "Limited", pro: "Full", systemImage: "bell.badge")
        }
        .stadiumCard(padding: 0)
    }

    func comparisonRow(feature: String, free: String, pro: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            IconCircle(systemImage: systemImage, color: .blue, size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 10) {
                    Text("Free: \(free)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("Pro: \(pro)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    var thinDivider: some View {
        Divider().padding(.leading, 66)
    }
}

// MARK: - Purchase

private extension PaywallView {
    var purchaseButton: some View {
        Button {
            Task { try? await storeService.purchase() }
        } label: {
            Group {
                if storeService.purchaseState == .purchasing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                        Text("Purchasing...")
                    }
                } else {
                    Text(buttonTitle)
                }
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(storeService.purchaseState == .purchasing)
    }

    var buttonTitle: String {
        if let product = storeService.product {
            return "Upgrade to Pro — \(product.displayPrice)"
        }
        return "Upgrade to Pro"
    }

    var restoreLink: some View {
        Button("Restore Purchases") {
            Task { await storeService.restorePurchases() }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
    .environment(\.dependencies, DependencyContainer())
}
