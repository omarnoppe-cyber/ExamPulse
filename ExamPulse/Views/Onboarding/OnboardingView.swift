import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("Welcome to ExamPulse")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Create exams, upload study documents, and turn them into summaries, flashcards, and quizzes.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 16) {
                onboardingRow(
                    title: "Create an exam",
                    detail: "Set your title and exam date first.",
                    systemImage: "calendar.badge.plus"
                )
                onboardingRow(
                    title: "Upload documents",
                    detail: "Import PDF, DOCX, and PPTX study material.",
                    systemImage: "doc.badge.plus"
                )
                onboardingRow(
                    title: "Study smarter",
                    detail: "Review summaries, flashcards, quizzes, and progress in one flow.",
                    systemImage: "brain.head.profile"
                )
            }

            Spacer()

            Button("Get Started") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(24)
        .navigationTitle("Onboarding")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func onboardingRow(title: String, detail: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                Text(detail)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView {}
    }
}
