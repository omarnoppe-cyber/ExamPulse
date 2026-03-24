import SwiftUI
import SwiftData

struct ExamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dependencies) private var dependencies
    let exam: Exam

    @State private var viewModel: ExamDetailViewModel?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                infoSection
                statusSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .themeCanvas()
        .navigationTitle(exam.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = ExamDetailViewModel(
                    generator: dependencies.studyContentGenerator,
                    apiKeyManager: dependencies.apiKeyManager,
                    entitlementManager: dependencies.entitlementManager
                )
            }
        }
    }
}

// MARK: - Info

private extension ExamDetailView {
    var infoSection: some View {
        VStack(spacing: 0) {
            infoRow("Exam Date", systemImage: "calendar", value: exam.examDate.shortFormatted)
            Divider().padding(.leading, 54)
            infoRow("Time Left", systemImage: "clock", value: exam.examDate.relativeDayDescription)
            Divider().padding(.leading, 54)
            infoRow("Documents", systemImage: "doc.on.doc", value: "\(exam.studyDocuments.count)")
        }
        .softCard(padding: 0)
    }

    func infoRow(_ title: String, systemImage: String, value: String) -> some View {
        HStack {
            Label {
                Text(title).foregroundStyle(.secondary)
            } icon: {
                Image(systemName: systemImage).foregroundStyle(.themePurple)
            }
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.themeDark)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

// MARK: - Status-dependent section

private extension ExamDetailView {
    @ViewBuilder
    var statusSection: some View {
        switch exam.status {
        case .ready: studyMaterialsSection
        case .new: generateSection
        case .generating: generatingSection
        case .error: errorSection
        case .parsing: generatingSection
        }
    }

    var generateSection: some View {
        VStack(spacing: 14) {
            Button {
                Task { await viewModel?.generateStudyMaterials(for: exam, context: modelContext) }
            } label: {
                Label("Generate Study Materials", systemImage: "sparkles")
            }
            .buttonStyle(.primary)
            .disabled(!(viewModel?.apiKeyManager.hasAPIKey ?? false))

            if !(viewModel?.apiKeyManager.hasAPIKey ?? false) {
                Text("Add your OpenAI API key in Settings to generate materials.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .softCard()
    }

    var generatingSection: some View {
        HStack(spacing: 12) {
            ProgressView().controlSize(.small)
            Text("Generating study materials...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .softCard()
    }

    var errorSection: some View {
        VStack(spacing: 12) {
            if let error = viewModel?.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }
            Button("Retry") {
                Task { await viewModel?.generateStudyMaterials(for: exam, context: modelContext) }
            }
            .buttonStyle(.primary)
        }
        .softCard()
    }
}

// MARK: - Study Materials

private extension ExamDetailView {
    var sortedTopics: [Topic] {
        exam.topics.sorted { $0.sortOrder < $1.sortOrder }
    }

    var studyMaterialsSection: some View {
        VStack(spacing: 12) {
            if !exam.summaryText.isEmpty {
                NavigationLink {
                    SummaryView(summaryText: exam.summaryText, topics: sortedTopics)
                } label: {
                    DisclosureRow(title: "Summary", subtitle: "AI-generated overview") {
                        IconCircle(systemImage: "doc.text", color: .themePurple)
                    }
                    .softCard()
                }
                .buttonStyle(.plain)
            }

            if !sortedTopics.isEmpty {
                flashcardsRow
                quizRow
            }
        }
    }

    var flashcardsRow: some View {
        let all = sortedTopics.flatMap(\.flashcards)
        return NavigationLink {
            topicFlashcardsPicker(topics: sortedTopics)
        } label: {
            DisclosureRow(
                title: "Flashcards",
                subtitle: "\(all.filter(\.isLearned).count)/\(all.count) learned"
            ) {
                IconCircle(systemImage: "rectangle.on.rectangle.angled", color: .themePeach)
            }
            .softCard()
        }
        .buttonStyle(.plain)
    }

    var quizRow: some View {
        NavigationLink {
            topicQuizPicker(topics: sortedTopics)
        } label: {
            DisclosureRow(
                title: "Quiz",
                subtitle: "\(sortedTopics.flatMap(\.questions).count) questions"
            ) {
                IconCircle(systemImage: "questionmark.circle", color: .themePurple)
            }
            .softCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Topic Pickers

private extension ExamDetailView {
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
}
