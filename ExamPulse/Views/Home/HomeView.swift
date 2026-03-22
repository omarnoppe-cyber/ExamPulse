import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingHeader
                    countdownCard
                    studyActionsSection
                    upcomingExamsSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("ExamPulse")
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting())
                .font(.title2)
                .fontWeight(.bold)

            if let exam = viewModel.nextExam(from: exams) {
                Text("Your next exam is **\(exam.title)**")
                    .foregroundStyle(.secondary)
            } else {
                Text("No upcoming exams. Create one to get started.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Countdown

    private var countdownCard: some View {
        Group {
            if let exam = viewModel.nextExam(from: exams) {
                let countdown = viewModel.countdownComponents(for: exam)

                card {
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            countdownUnit(value: countdown.days, label: "days")
                            countdownUnit(value: countdown.hours, label: "hours")
                        }

                        Text("until \(exam.title)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Divider()

                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.blue)
                                .font(.subheadline)

                            Text("Next reminder: \(viewModel.nextReminderDescription(for: exam))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                card {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("Create an exam to see your countdown")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private func countdownUnit(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
    }

    // MARK: - Study Actions

    private var studyActionsSection: some View {
        Group {
            if let exam = viewModel.nextExam(from: exams), exam.status == .ready {
                let sortedTopics = exam.topics.sorted { $0.sortOrder < $1.sortOrder }

                VStack(spacing: 12) {
                    Text("Study")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    NavigationLink {
                        topicQuizPicker(topics: sortedTopics)
                    } label: {
                        actionRow(
                            title: "Start Quiz",
                            subtitle: "\(exam.questions.count) questions",
                            systemImage: "questionmark.circle.fill",
                            color: .blue
                        )
                    }

                    NavigationLink {
                        topicFlashcardsPicker(topics: sortedTopics)
                    } label: {
                        actionRow(
                            title: "Review Flashcards",
                            subtitle: "\(viewModel.dueFlashcardCount(for: exam)) due",
                            systemImage: "rectangle.on.rectangle.angled",
                            color: .orange
                        )
                    }

                    NavigationLink {
                        SummaryView(summaryText: exam.summaryText, topics: sortedTopics)
                    } label: {
                        actionRow(
                            title: "View Summary",
                            subtitle: exam.title,
                            systemImage: "doc.text.fill",
                            color: .green
                        )
                    }
                }
            }
        }
    }

    private func actionRow(title: String, subtitle: String, systemImage: String, color: Color) -> some View {
        card {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.quaternary)
            }
        }
    }

    // MARK: - Upcoming Exams

    private var upcomingExamsSection: some View {
        VStack(spacing: 12) {
            Text("Upcoming Exams")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if exams.isEmpty {
                card {
                    NavigationLink {
                        ExamSetupView()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Create Your First Exam")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.quaternary)
                        }
                    }
                }
            } else {
                ForEach(exams.prefix(5)) { exam in
                    NavigationLink {
                        ExamDetailView(exam: exam)
                    } label: {
                        card {
                            ExamRowView(exam: exam)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Topic Pickers

    private func topicQuizPicker(topics: [Topic]) -> some View {
        List(topics, id: \.id) { topic in
            NavigationLink {
                QuizView(viewModel: QuizViewModel(questions: topic.questions))
                    .navigationTitle(topic.title)
            } label: {
                HStack {
                    Text(topic.title)
                    Spacer()
                    Text("\(topic.questions.count) Qs")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Quiz by Topic")
    }

    private func topicFlashcardsPicker(topics: [Topic]) -> some View {
        List(topics, id: \.id) { topic in
            NavigationLink {
                FlashcardView(viewModel: FlashcardViewModel(flashcards: topic.flashcards))
                    .navigationTitle(topic.title)
            } label: {
                HStack {
                    Text(topic.title)
                    Spacer()
                    Text("\(topic.learnedFlashcardsCount)/\(topic.flashcards.count)")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Flashcards by Topic")
    }

    // MARK: - Card Helper

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
    }
}
