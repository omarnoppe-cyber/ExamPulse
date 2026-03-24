import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @Environment(\.dependencies) private var dependencies

    private var allAttempts: [AnswerAttempt] {
        exams.flatMap { $0.questions.flatMap(\.answerAttempts) }
    }

    private var accuracy: Double {
        guard !allAttempts.isEmpty else { return 0 }
        return Double(allAttempts.filter(\.wasCorrect).count) / Double(allAttempts.count)
    }

    private var flashcardsReviewed: Int {
        exams.flatMap(\.flashcards).filter { $0.reviewCount > 0 }.count
    }

    private var daysRemaining: Int? {
        guard let next = exams.first(where: { $0.examDate > Date() }) else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: next.examDate).day
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                accuracyCard
                statsRow
                weakTopicsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .themeCanvas()
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Accuracy Card

private extension ProgressDashboardView {
    var accuracyCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Quiz Accuracy")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.themeDark)
                Text("\(allAttempts.count) total attempts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ScoreRing(value: accuracy, size: 64, lineWidth: 6)
        }
        .softCard()
    }
}

// MARK: - Stats Row

private extension ProgressDashboardView {
    var statsRow: some View {
        HStack(spacing: 14) {
            statCard(value: "\(flashcardsReviewed)", label: "Flashcards\nreviewed", icon: "rectangle.on.rectangle.angled", color: .themePeach)
            statCard(value: daysRemaining.map { "\($0)" } ?? "—", label: "Days\nremaining", icon: "calendar", color: .themePurple)
        }
    }

    func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            IconCircle(systemImage: icon, color: color, size: 36)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.themeDark)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2, reservesSpace: true)
        }
        .softCard()
    }
}

// MARK: - Weak Topics

private extension ProgressDashboardView {
    var weakTopicsSection: some View {
        VStack(spacing: 14) {
            SectionHeader(title: "Focus Areas")

            let weakTopics = exams.flatMap(\.topics)
                .filter { $0.masteryScore < 0.6 }
                .sorted { $0.masteryScore < $1.masteryScore }
                .prefix(5)

            if weakTopics.isEmpty {
                Text("No weak topics yet. Keep studying!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(weakTopics.enumerated()), id: \.element.id) { index, topic in
                        if index > 0 { Divider().padding(.leading, 54) }
                        weakTopicRow(topic)
                    }
                }
                .softCard(padding: 0)
            }
        }
    }

    func weakTopicRow(_ topic: Topic) -> some View {
        HStack(spacing: 14) {
            IconCircle(systemImage: "exclamationmark.triangle", color: .orange, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(topic.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.themeDark)
                Text("Mastery: \(Int(topic.masteryScore * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ProgressDashboardView()
        .modelContainer(for: Exam.self, inMemory: true)
        .environment(\.dependencies, DependencyContainer())
}
