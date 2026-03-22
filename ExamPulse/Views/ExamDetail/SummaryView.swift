import SwiftUI

struct SummaryView: View {
    let summaryText: String
    @State private var viewModel: SummaryViewModel

    init(summaryText: String, topics: [Topic]) {
        self.summaryText = summaryText
        _viewModel = State(initialValue: SummaryViewModel(summaryText: summaryText, topics: topics))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                studyActions
                summarySection
                topicsSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Study Actions

private extension SummaryView {
    var studyActions: some View {
        VStack(spacing: 12) {
            NavigationLink {
                topicQuizPicker
            } label: {
                Label("Start Quiz", systemImage: "questionmark.circle.fill")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.totalQuestionCount == 0)

            NavigationLink {
                topicFlashcardsPicker
            } label: {
                Label("Review Flashcards", systemImage: "rectangle.on.rectangle.angled")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.totalFlashcardCount == 0)
        }
    }
}

// MARK: - Summary Section

private extension SummaryView {
    var summarySection: some View {
        contentCard(title: "Summary", systemImage: "doc.text") {
            Text(LocalizedStringKey(viewModel.summaryText))
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Topics Section

private extension SummaryView {
    var topicsSection: some View {
        contentCard(title: "Topics", systemImage: "list.bullet.rectangle") {
            if viewModel.sortedTopics.isEmpty {
                Text("Topics will appear here after study material is generated.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.sortedTopics, id: \.id) { topic in
                        topicRow(topic)
                    }
                }
            }
        }
    }

    func topicRow(_ topic: Topic) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(topic.flashcards.count) flashcards \u{2022} \(topic.questions.count) questions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}

// MARK: - Topic Pickers

private extension SummaryView {
    var topicFlashcardsPicker: some View {
        List(viewModel.sortedTopics, id: \.id) { topic in
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

    var topicQuizPicker: some View {
        List(viewModel.sortedTopics, id: \.id) { topic in
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

// MARK: - Content Card Helper

private extension SummaryView {
    func contentCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            content()
        }
        .stadiumCard()
    }
}
