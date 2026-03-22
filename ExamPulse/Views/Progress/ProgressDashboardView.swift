import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @State private var viewModel = ProgressViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                accuracySection
                flashcardsSection
                weakTopicsSection
                daysRemainingSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Progress")
    }

    private var accuracySection: some View {
        progressCard(
            title: "Accuracy Percentage",
            value: "\(viewModel.accuracyPercentage(in: exams))%",
            systemImage: "target",
            color: .blue,
            progress: Double(viewModel.accuracyPercentage(in: exams)) / 100
        ) {
            Text("Based on answered quiz questions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var flashcardsSection: some View {
        progressCard(
            title: "Flashcards Reviewed",
            value: "\(viewModel.flashcardsReviewed(in: exams))",
            systemImage: "rectangle.on.rectangle.angled",
            color: .orange,
            progress: viewModel.flashcardsReviewedProgress(in: exams)
        ) {
            Text("\(exams.flatMap(\.flashcards).filter { $0.reviewCount > 0 }.count) of \(viewModel.totalFlashcards(in: exams)) cards reviewed at least once")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var weakTopicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Weak Topics", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            let weakTopics = Array(viewModel.weakTopics(in: exams).prefix(3))
            if weakTopics.isEmpty {
                Text("Weak topics will appear here after you start reviewing flashcards or answering quiz questions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(weakTopics, id: \.id) { topic in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(topic.title)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(Int(viewModel.topicWeaknessScore(topic) * 100))% weak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        ProgressView(value: viewModel.topicWeaknessScore(topic))
                            .tint(.red)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var daysRemainingSection: some View {
        progressCard(
            title: "Days Remaining",
            value: viewModel.daysRemaining(in: exams).map { "\($0)" } ?? "--",
            systemImage: "calendar",
            color: .green,
            progress: viewModel.daysRemainingProgress(in: exams)
        ) {
            Text(viewModel.daysRemaining(in: exams).map { _ in "Until your next exam" } ?? "Create an exam to track time remaining")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func progressCard<Content: View>(
        title: String,
        value: String,
        systemImage: String,
        color: Color,
        progress: Double,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(color)

                Spacer()

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }

            ProgressView(value: min(max(progress, 0), 1))
                .tint(color)

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.background)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
    }
}
