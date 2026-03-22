import SwiftUI
import SwiftData

struct ExamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dependencies) private var dependencies
    let exam: Exam

    @State private var viewModel: ExamDetailViewModel?

    var body: some View {
        List {
            examInfoSection

            if exam.status == .ready {
                studyMaterialsSection
            } else if exam.status == .new {
                generateSection
            } else if exam.status == .generating {
                generatingSection
            } else if exam.status == .error {
                errorSection
            }
        }
        .navigationTitle(exam.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = ExamDetailViewModel(
                    aiService: dependencies.aiService,
                    apiKeyManager: dependencies.apiKeyManager
                )
            }
        }
    }

    // MARK: - Sections

    private var examInfoSection: some View {
        Section {
            HStack {
                Label("Exam Date", systemImage: "calendar")
                Spacer()
                Text(exam.examDate.shortFormatted)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Time Left", systemImage: "clock")
                Spacer()
                Text(exam.examDate.relativeDayDescription)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Documents", systemImage: "doc.on.doc")
                Spacer()
                Text("\(exam.documents.count)")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var generateSection: some View {
        Section {
            Button {
                Task {
                    await viewModel?.generateStudyMaterials(for: exam, context: modelContext)
                }
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

    private var generatingSection: some View {
        Section {
            HStack {
                ProgressView()
                    .controlSize(.small)
                Text("Generating study materials...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
        }
    }

    private var errorSection: some View {
        Section {
            VStack(spacing: 12) {
                if let error = viewModel?.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }

                Button("Retry") {
                    Task {
                        await viewModel?.generateStudyMaterials(for: exam, context: modelContext)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private var studyMaterialsSection: some View {
        Section("Study Materials") {
            if let summary = exam.summary {
                NavigationLink {
                    SummaryView(summary: summary)
                } label: {
                    Label("Summary", systemImage: "doc.text")
                }
            }

            let sortedTopics = exam.topics.sorted { $0.sortOrder < $1.sortOrder }
            if !sortedTopics.isEmpty {
                NavigationLink {
                    topicFlashcardsPicker(topics: sortedTopics)
                } label: {
                    Label {
                        HStack {
                            Text("Flashcards")
                            Spacer()
                            let total = sortedTopics.flatMap(\.flashcards).count
                            let learned = sortedTopics.flatMap(\.flashcards).filter(\.isLearned).count
                            Text("\(learned)/\(total)")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "rectangle.on.rectangle.angled")
                    }
                }

                NavigationLink {
                    topicQuizPicker(topics: sortedTopics)
                } label: {
                    Label {
                        HStack {
                            Text("Quiz")
                            Spacer()
                            let total = sortedTopics.flatMap(\.quizQuestions).count
                            Text("\(total) questions")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
        }
    }

    // MARK: - Topic pickers

    private func topicFlashcardsPicker(topics: [Topic]) -> some View {
        List(topics, id: \.id) { topic in
            NavigationLink {
                FlashcardView(
                    viewModel: FlashcardViewModel(flashcards: topic.flashcards)
                )
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

    private func topicQuizPicker(topics: [Topic]) -> some View {
        List(topics, id: \.id) { topic in
            NavigationLink {
                QuizView(
                    viewModel: QuizViewModel(questions: topic.quizQuestions)
                )
                .navigationTitle(topic.title)
            } label: {
                HStack {
                    Text(topic.title)
                    Spacer()
                    Text("\(topic.quizQuestions.count) Qs")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Quiz by Topic")
    }
}
