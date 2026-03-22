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
}

// MARK: - Accuracy

private extension ProgressDashboardView {
    var accuracySection: some View {
        let accuracy = viewModel.accuracyPercentage(in: exams)
        return metricCard(
            title: "Accuracy",
            value: "\(accuracy)%",
            systemImage: "target",
            color: .blue,
            progress: Double(accuracy) / 100,
            detail: "Based on answered quiz questions"
        )
    }
}

// MARK: - Flashcards

private extension ProgressDashboardView {
    var flashcardsSection: some View {
        let reviewed = viewModel.flashcardsReviewed(in: exams)
        let total = viewModel.totalFlashcards(in: exams)
        return metricCard(
            title: "Flashcards Reviewed",
            value: "\(reviewed)",
            systemImage: "rectangle.on.rectangle.angled",
            color: .orange,
            progress: viewModel.flashcardsReviewedProgress(in: exams),
            detail: "\(reviewed) of \(total) cards reviewed at least once"
        )
    }
}

// MARK: - Weak Topics

private extension ProgressDashboardView {
    var weakTopicsSection: some View {
        let topics = Array(viewModel.weakTopics(in: exams).prefix(3))
        return VStack(alignment: .leading, spacing: 16) {
            Label("Weak Topics", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            if topics.isEmpty {
                Text("Weak topics will appear here after you start reviewing flashcards or answering quiz questions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(topics, id: \.id) { topic in
                    weakTopicRow(topic)
                }
            }
        }
        .stadiumCard()
    }

    func weakTopicRow(_ topic: Topic) -> some View {
        let score = viewModel.topicWeaknessScore(topic)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(topic.title)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(score * 100))% weak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            capsuleProgress(value: score, tint: .red)
        }
    }
}

// MARK: - Days Remaining

private extension ProgressDashboardView {
    var daysRemainingSection: some View {
        let days = viewModel.daysRemaining(in: exams)
        return metricCard(
            title: "Days Remaining",
            value: days.map { "\($0)" } ?? "--",
            systemImage: "calendar",
            color: .green,
            progress: viewModel.daysRemainingProgress(in: exams),
            detail: days != nil ? "Until your next exam" : "Create an exam to track time remaining"
        )
    }
}

// MARK: - Reusable Card

private extension ProgressDashboardView {
    func metricCard(
        title: String,
        value: String,
        systemImage: String,
        color: Color,
        progress: Double,
        detail: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                IconCircle(systemImage: systemImage, color: color, size: 36)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            capsuleProgress(value: progress, tint: color)

            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .stadiumCard()
    }

    func capsuleProgress(value: Double, tint: Color) -> some View {
        GeometryReader { geo in
            let clamped = min(max(value, 0), 1)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tint.opacity(0.12))

                Capsule()
                    .fill(tint.gradient)
                    .frame(width: geo.size.width * clamped)
                    .animation(.easeInOut(duration: 0.5), value: clamped)
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}
