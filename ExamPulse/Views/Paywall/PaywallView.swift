import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)?

    @State private var contentVisible = false

    private var storeService: StoreServicing { dependencies.storeService }
    private var entitlementManager: EntitlementManaging { dependencies.entitlementManager }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                heroSection
                featuresList
                purchaseButton
                restoreLink
            }
            .padding(24)
        }
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 14)
        .themeCanvas()
        .navigationTitle("Go Pro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if onDismiss != nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        withAnimation(AppAnimation.root) {
                            onDismiss?()
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(AppAnimation.content) {
                contentVisible = true
            }
        }
        .onChange(of: storeService.purchaseState) { _, newState in
            if newState == .purchased {
                if let onDismiss {
                    withAnimation(AppAnimation.root) {
                        onDismiss()
                    }
                } else {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Hero

private extension PaywallView {
    var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                GradientBlob(size: 160)
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(height: 180)

            Text("Unlock **ExamPulse Pro**")
                .font(.title2)
                .foregroundStyle(.themeDark)

            Text("Get unlimited study tools and stay\nfully prepared for every exam.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Features

private extension PaywallView {
    var featuresList: some View {
        VStack(spacing: 0) {
            featureRow(title: "Unlimited Exams", detail: "Free: 1", systemImage: "calendar.badge.plus", color: .themePurple)
            Divider().padding(.leading, 60)
            featureRow(title: "Unlimited Flashcards", detail: "Free: 10/exam", systemImage: "rectangle.on.rectangle.angled", color: .themePeach)
            Divider().padding(.leading, 60)
            featureRow(title: "Unlimited Questions", detail: "Free: 5/exam", systemImage: "questionmark.circle", color: .themePurple)
            Divider().padding(.leading, 60)
            featureRow(title: "Full Exam Reminders", detail: "Free: Limited", systemImage: "bell.badge", color: .themePeach)
        }
        .softCard(padding: 0)
    }

    func featureRow(title: String, detail: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 14) {
            IconCircle(systemImage: systemImage, color: color, size: 38)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.semibold).foregroundStyle(.themeDark)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
                        ProgressView().controlSize(.small).tint(.white)
                        Text("Purchasing...")
                    }
                } else {
                    Text(buttonTitle)
                }
            }
        }
        .buttonStyle(.primary)
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
    NavigationStack { PaywallView() }
        .environment(\.dependencies, DependencyContainer())
}
