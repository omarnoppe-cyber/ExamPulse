import SwiftUI

struct PaywallView: View {
    let onUpgrade: () -> Void

    init(onUpgrade: @escaping () -> Void = {}) {
        self.onUpgrade = onUpgrade
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                benefitsCard
                upgradeButton
            }
            .padding(24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Go Pro")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 44))
                .foregroundStyle(.blue)

            Text("Unlock ExamPulse Pro")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Get unlimited study tools and stay fully prepared for every exam.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            benefitRow(
                title: "Unlimited exams",
                systemImage: "calendar.badge.plus"
            )
            benefitRow(
                title: "Unlimited flashcards",
                systemImage: "rectangle.on.rectangle.angled"
            )
            benefitRow(
                title: "Unlimited quiz questions",
                systemImage: "questionmark.circle"
            )
            benefitRow(
                title: "Exam reminders",
                systemImage: "bell.badge"
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }

    private var upgradeButton: some View {
        Button("Upgrade to Pro") {
            onUpgrade()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
    }

    private func benefitRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)

            Text(title)
                .font(.headline)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
}
