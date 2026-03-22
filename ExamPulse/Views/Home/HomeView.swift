import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel = HomeViewModel()

    private var isPro: Bool { dependencies.entitlementManager.isPro }
    private var nextExam: Exam? { viewModel.nextExam(from: exams) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingHeader
                    if !isPro { upgradeBanner }
                    countdownSection
                    studyActionsSection
                    upcomingExamsSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("ExamPulse")
        }
    }
}

// MARK: - Upgrade Banner

private extension HomeView {
    var upgradeBanner: some View {
        NavigationLink {
            PaywallView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Pro")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("Unlimited exams, flashcards & questions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
            }
            .stadiumCard()
        }
    }
}

// MARK: - Greeting

private extension HomeView {
    var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting())
                .font(.title2)
                .fontWeight(.bold)

            if let exam = nextExam {
                Text("Your next exam is **\(exam.title)**")
                    .foregroundStyle(.secondary)
            } else {
                Text("No upcoming exams. Create one to get started.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Countdown

private extension HomeView {
    var countdownSection: some View {
        Group {
            if let exam = nextExam {
                examCountdown(exam)
            } else {
                emptyCountdown
            }
        }
    }

    func examCountdown(_ exam: Exam) -> some View {
        let countdown = viewModel.countdownComponents(for: exam)
        return VStack(spacing: 16) {
            HStack(spacing: 28) {
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
                    .font(.caption)
                Text("Next reminder: \(viewModel.nextReminderDescription(for: exam))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .stadiumCard()
    }

    func countdownUnit(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
    }

    var emptyCountdown: some View {
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
        .stadiumCard()
    }
}

// MARK: - Study Actions

private extension HomeView {
    var studyActionsSection: some View {
        Group {
            if let exam = nextExam, exam.status == .ready {
                let topics = exam.topics.sorted { $0.sortOrder < $1.sortOrder }

                VStack(spacing: 12) {
                    sectionHeader("Study")

                    NavigationLink {
                        topicQuizPicker(topics: topics)
                    } label: {
                        studyActionRow(
                            title: "Start Quiz",
                            subtitle: "\(exam.questions.count) questions",
                            systemImage: "questionmark.circle.fill",
                            color: .blue
                        )
                    }

                    NavigationLink {
                        topicFlashcardsPicker(topics: topics)
                    } label: {
                        studyActionRow(
                            title: "Review Flashcards",
                            subtitle: "\(viewModel.dueFlashcardCount(for: exam)) due",
                            systemImage: "rectangle.on.rectangle.angled",
                            color: .orange
                        )
                    }

                    NavigationLink {
                        SummaryView(summaryText: exam.summaryText, topics: topics)
                    } label: {
                        studyActionRow(
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

    func studyActionRow(title: String, subtitle: String, systemImage: String, color: Color) -> some View {
        DisclosureRow(title: title, subtitle: subtitle) {
            IconCircle(systemImage: systemImage, color: color)
        }
        .stadiumCard()
    }
}

// MARK: - Upcoming Exams

private extension HomeView {
    var upcomingExamsSection: some View {
        VStack(spacing: 12) {
            sectionHeader("Upcoming Exams")

            if exams.isEmpty {
                createExamRow
            } else if !isPro && exams.count >= dependencies.entitlementManager.maxFreeExams {
                upgradeLockRow
            } else {
                ForEach(exams.prefix(5)) { exam in
                    NavigationLink {
                        ExamDetailView(exam: exam)
                    } label: {
                        ExamRowView(exam: exam)
                            .stadiumCard()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    var createExamRow: some View {
        NavigationLink {
            ExamSetupView()
        } label: {
            DisclosureRow(title: "Create Your First Exam", subtitle: "Upload study material to get started") {
                IconCircle(systemImage: "plus", color: .blue)
            }
            .stadiumCard()
        }
    }

    var upgradeLockRow: some View {
        NavigationLink {
            PaywallView()
        } label: {
            DisclosureRow(title: "Upgrade to add more exams", subtitle: "Free tier allows 1 exam") {
                IconCircle(systemImage: "lock.fill", color: .orange)
            }
            .stadiumCard()
        }
    }
}

// MARK: - Topic Pickers

private extension HomeView {
    func topicQuizPicker(topics: [Topic]) -> some View {
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

    func topicFlashcardsPicker(topics: [Topic]) -> some View {
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
}

// MARK: - Helpers

private extension HomeView {
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
