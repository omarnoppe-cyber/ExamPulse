import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel = HomeViewModel()
    @State private var showingPaywall = false
    @State private var showingAllExams = false

    private var isPro: Bool { dependencies.entitlementManager.isPro }
    private var nextExam: Exam? { viewModel.nextExam(from: exams) }

    private var canCreateExam: Bool {
        isPro || exams.count < dependencies.entitlementManager.maxFreeExams
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    greetingHeader
                    if !isPro { proCard }
                    quickActions
                    nextExamSection
                    examHistorySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .themeCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPaywall) {
                NavigationStack { PaywallView() }
            }
            .sheet(isPresented: $showingAllExams) {
                NavigationStack {
                    allExamsList
                }
            }
        }
    }
}

// MARK: - Greeting

private extension HomeView {
    var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.greeting())
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.themeDark)

            if let exam = nextExam {
                Text("Your next exam is **\(exam.title)**")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("How may I help you today?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Pro Upgrade Card

private extension HomeView {
    var proCard: some View {
        NavigationLink {
            PaywallView()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x7B79E8), Color.themePurple, Color(hex: 0x5553C7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .fill(Color.themePeach.opacity(0.3))
                    .frame(width: 140, height: 140)
                    .blur(radius: 50)
                    .offset(x: 110, y: -40)

                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .blur(radius: 30)
                    .offset(x: -80, y: 50)

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles").font(.caption2)
                            Text("PRO").font(.caption2).fontWeight(.heavy).tracking(1.5)
                        }
                        .foregroundStyle(.white.opacity(0.7))

                        Text("Unlock the full\npower of ExamPulse")
                            .font(.title3).fontWeight(.bold)
                            .foregroundStyle(.white).lineSpacing(3)

                        VStack(alignment: .leading, spacing: 6) {
                            proFeatureRow("Unlimited exams")
                            proFeatureRow("Unlimited flashcards")
                            proFeatureRow("Unlimited quiz questions")
                        }
                        .padding(.top, 2)

                        Text("Upgrade now")
                            .font(.footnote).fontWeight(.semibold)
                            .foregroundStyle(.themePurple)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(.white, in: Capsule())
                            .padding(.top, 4)
                    }
                    Spacer()
                }
                .padding(22)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func proFeatureRow(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.themePeach)
            Text(text).font(.caption).foregroundStyle(.white.opacity(0.85))
        }
    }
}

// MARK: - Quick Actions

private extension HomeView {
    var quickActions: some View {
        Group {
            if let exam = nextExam, exam.status == .ready {
                let topics = exam.topics.sorted { $0.sortOrder < $1.sortOrder }
                readyStudyActions(topics: topics, exam: exam)
            } else {
                defaultQuickActions
            }
        }
    }

    func readyStudyActions(topics: [Topic], exam: Exam) -> some View {
        HStack(spacing: 12) {
            NavigationLink {
                topicQuizPicker(topics: topics)
            } label: {
                actionTile(title: "Quiz", subtitle: "\(topics.flatMap(\.questions).count) Qs",
                           systemImage: "questionmark.circle", color: .themePurple)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            NavigationLink {
                topicFlashcardsPicker(topics: topics)
            } label: {
                actionTile(title: "Flashcards", subtitle: "\(topics.flatMap(\.flashcards).count) cards",
                           systemImage: "rectangle.on.rectangle.angled", color: .themePeach)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            NavigationLink {
                SummaryView(summaryText: exam.summaryText, topics: topics)
            } label: {
                actionTile(title: "Summary", subtitle: "Overview",
                           systemImage: "doc.text", color: .themePurple)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }

    var defaultQuickActions: some View {
        HStack(spacing: 12) {
            Group {
                if canCreateExam {
                    NavigationLink {
                        ExamSetupView()
                    } label: {
                        actionTile(title: "New Exam", subtitle: "Get started",
                                   systemImage: "plus.circle", color: .themePurple)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                } else {
                    Button {
                        showingPaywall = true
                    } label: {
                        actionTile(title: "New Exam", subtitle: "Get started",
                                   systemImage: "plus.circle", color: .themePurple)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }

            actionTile(title: "Flashcards", subtitle: "Study",
                       systemImage: "rectangle.on.rectangle.angled", color: .themePeach, dimmed: true)
                .frame(maxWidth: .infinity)

            actionTile(title: "Quiz", subtitle: "Practice",
                       systemImage: "questionmark.circle", color: .themePurple, dimmed: true)
                .frame(maxWidth: .infinity)
        }
    }

    func actionTile(title: String, subtitle: String, systemImage: String, color: Color, dimmed: Bool = false) -> some View {
        VStack(spacing: 12) {
            IconCircle(systemImage: systemImage, color: color, size: 52)
            VStack(spacing: 3) {
                Text(title).font(.subheadline).fontWeight(.semibold).foregroundStyle(.themeDark)
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(.themeSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        .opacity(dimmed ? 0.4 : 1)
    }
}

// MARK: - Next Exam Section

private extension HomeView {
    @ViewBuilder
    var nextExamSection: some View {
        if let exam = nextExam {
            switch exam.status {
            case .ready:
                countdownCard(exam)

            case .new:
                NavigationLink {
                    ExamDetailView(exam: exam)
                } label: {
                    statusCard(exam, icon: "sparkles", message: "Tap to generate study materials", color: .themePurple)
                }
                .buttonStyle(.plain)

            case .generating, .parsing:
                statusCard(exam, icon: "hourglass", message: "Generating study materials...", color: .themePeach)

            case .error:
                NavigationLink {
                    ExamDetailView(exam: exam)
                } label: {
                    statusCard(exam, icon: "exclamationmark.triangle", message: "Generation failed. Tap to retry.", color: .red)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func countdownCard(_ exam: Exam) -> some View {
        NavigationLink {
            ExamDetailView(exam: exam)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(exam.title)
                        .font(.subheadline).fontWeight(.semibold).foregroundStyle(.themeDark)
                    // Match ExamDetailView info rows: calendar date + same "Time Left" string as relativeDayDescription.
                    Text(exam.examDate.shortFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(exam.examDate.relativeDayDescription)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.themeDark)
                }
                Spacer()
                ScoreRing(value: examAccuracy(exam), size: 56, lineWidth: 5)
            }
            .softCard()
        }
        .buttonStyle(.plain)
    }

    func statusCard(_ exam: Exam, icon: String, message: String, color: Color) -> some View {
        HStack(spacing: 14) {
            IconCircle(systemImage: icon, color: color, size: 42)
            VStack(alignment: .leading, spacing: 3) {
                Text(exam.title).font(.subheadline).fontWeight(.semibold).foregroundStyle(.themeDark)
                Text(message).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption2).fontWeight(.semibold).foregroundStyle(.quaternary)
        }
        .softCard()
    }

    func examAccuracy(_ exam: Exam) -> Double {
        let attempts = exam.questions.flatMap(\.answerAttempts)
        guard !attempts.isEmpty else { return 0 }
        return Double(attempts.filter(\.wasCorrect).count) / Double(attempts.count)
    }
}

// MARK: - Exam History

private extension HomeView {
    var examHistorySection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("History")
                    .font(.title3).fontWeight(.bold).foregroundStyle(.themeDark)
                Spacer()
                if exams.count > 3 {
                    Button("View all") { showingAllExams = true }
                        .font(.subheadline).foregroundStyle(.themePurple)
                }
            }

            if exams.isEmpty {
                emptyHistoryCard
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(exams.prefix(3).enumerated()), id: \.element.id) { index, exam in
                        if index > 0 { Divider().padding(.leading, 58) }
                        NavigationLink {
                            ExamDetailView(exam: exam)
                        } label: {
                            examHistoryRow(exam)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .softCard(padding: 0)
            }
        }
    }

    var emptyHistoryCard: some View {
        NavigationLink {
            ExamSetupView()
        } label: {
            VStack(spacing: 14) {
                Image(systemName: "tray")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.secondary.opacity(0.4))
                VStack(spacing: 4) {
                    Text("No exams yet")
                        .font(.subheadline).fontWeight(.semibold).foregroundStyle(.themeDark)
                    Text("Tap to create your first exam\nand start studying.")
                        .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .softCard()
        }
        .buttonStyle(.plain)
    }

    func examHistoryRow(_ exam: Exam) -> some View {
        HStack(spacing: 14) {
            IconCircle(
                systemImage: statusIcon(for: exam),
                color: statusColor(for: exam),
                size: 42
            )
            VStack(alignment: .leading, spacing: 3) {
                Text(exam.title).font(.subheadline).fontWeight(.semibold).foregroundStyle(.themeDark)
                Text(statusSubtitle(for: exam)).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2).fontWeight(.semibold).foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    func statusIcon(for exam: Exam) -> String {
        switch exam.status {
        case .ready: "checkmark"
        case .new: "doc.badge.plus"
        case .generating, .parsing: "hourglass"
        case .error: "exclamationmark.triangle"
        }
    }

    func statusColor(for exam: Exam) -> Color {
        switch exam.status {
        case .ready: .green
        case .new: .themePurple
        case .generating, .parsing: .themePeach
        case .error: .red
        }
    }

    func statusSubtitle(for exam: Exam) -> String {
        switch exam.status {
        case .ready: exam.examDate.relativeDayDescription
        case .new: "Ready to generate materials"
        case .generating, .parsing: "Generating..."
        case .error: "Failed — tap to retry"
        }
    }
}

// MARK: - All Exams Sheet

private extension HomeView {
    var allExamsList: some View {
        List {
            ForEach(exams) { exam in
                NavigationLink {
                    ExamDetailView(exam: exam)
                } label: {
                    HStack(spacing: 12) {
                        IconCircle(systemImage: statusIcon(for: exam), color: statusColor(for: exam), size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exam.title).font(.subheadline).fontWeight(.semibold)
                            Text(statusSubtitle(for: exam)).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("All Exams")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { showingAllExams = false }
            }
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
                    Text("\(topic.questions.count) Qs").foregroundStyle(.secondary)
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
                    Text("\(topic.learnedFlashcardsCount)/\(topic.flashcards.count)").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Flashcards by Topic")
    }
}
