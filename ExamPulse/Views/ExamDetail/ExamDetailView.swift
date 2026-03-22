import SwiftUI
import SwiftData

struct ExamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dependencies) private var dependencies
    let exam: Exam

    @State private var viewModel: ExamDetailViewModel?

    var body: some View {
        List {
            infoSection
            statusSection
        }
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
        Section {
            infoRow("Exam Date", systemImage: "calendar", value: exam.examDate.shortFormatted)
            infoRow("Time Left", systemImage: "clock", value: exam.examDate.relativeDayDescription)
            infoRow("Documents", systemImage: "doc.on.doc", value: "\(exam.studyDocuments.count)")
        }
    }

    func infoRow(_ title: String, systemImage: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
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
        Section {
            Button {
                Task { await viewModel?.generateStudyMaterials(for: exam, context: modelContext) }
            } label: {
                Label("Generate Study Materials", systemImage: "sparkles")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fontWeight(.semibold)
            }
            .disabled(!(viewModel?.apiKeyManager.hasAPIKey ?? false))
        } footer: {
            if !(viewModel?.apiKeyManager.hasAPIKey ?? false) {
                Text("Add your OpenAI API key in Settings to generate materials.")
            }
        }
    }

    var generatingSection: some View {
        Section {
            HStack {
                ProgressView().controlSize(.small)
                Text("Generating study materials...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
        }
    }

    var errorSection: some View {
        Section {
            VStack(spacing: 12) {
                if let error = viewModel?.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
                Button("Retry") {
                    Task { await viewModel?.generateStudyMaterials(for: exam, context: modelContext) }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Study Materials

private extension ExamDetailView {
    var sortedTopics: [Topic] {
        exam.topics.sorted { $0.sortOrder < $1.sortOrder }
    }

    var studyMaterialsSection: some View {
        Section("Study Materials") {
            if !exam.summaryText.isEmpty {
                NavigationLink {
                    SummaryView(summaryText: exam.summaryText, topics: sortedTopics)
                } label: {
                    Label("Summary", systemImage: "doc.text")
                }
            }

            if !sortedTopics.isEmpty {
                flashcardsRow
                quizRow
            }
        }
    }

    var flashcardsRow: some View {
        NavigationLink {
            topicFlashcardsPicker(topics: sortedTopics)
        } label: {
            Label {
                HStack {
                    Text("Flashcards")
                    Spacer()
                    let all = sortedTopics.flatMap(\.flashcards)
                    Text("\(all.filter(\.isLearned).count)/\(all.count)")
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "rectangle.on.rectangle.angled")
            }
        }
    }

    var quizRow: some View {
        NavigationLink {
            topicQuizPicker(topics: sortedTopics)
        } label: {
            Label {
                HStack {
                    Text("Quiz")
                    Spacer()
                    Text("\(sortedTopics.flatMap(\.questions).count) questions")
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "questionmark.circle")
            }
        }
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
