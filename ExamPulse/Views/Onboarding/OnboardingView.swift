import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            GradientHero(
                systemImage: "brain.head.profile",
                title: "Welcome to ExamPulse",
                subtitle: "Create exams, upload study documents, and turn them into summaries, flashcards, and quizzes.",
                gradient: [.blue, .purple]
            )

            VStack(spacing: 14) {
                featureRow(
                    title: "Create an exam",
                    detail: "Set your title and exam date first.",
                    systemImage: "calendar.badge.plus",
                    color: .blue
                )
                featureRow(
                    title: "Upload documents",
                    detail: "Import PDF, DOCX, and PPTX study material.",
                    systemImage: "doc.badge.plus",
                    color: .orange
                )
                featureRow(
                    title: "Study smarter",
                    detail: "Summaries, flashcards, quizzes, and progress in one flow.",
                    systemImage: "sparkles",
                    color: .purple
                )
            }

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .navigationTitle("Onboarding")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func featureRow(title: String, detail: String, systemImage: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            IconCircle(systemImage: systemImage, color: color, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .stadiumCard(padding: 14)
    }
}

#Preview {
    NavigationStack {
        OnboardingView {}
    }
}
