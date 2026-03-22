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
                actionButtons
                summarySection
                topicsSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink {
                topicQuizPicker
            } label: {
                Label("Start Quiz", systemImage: "questionmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.totalQuestionCount == 0)

            NavigationLink {
                topicFlashcardsPicker
            } label: {
                Label("Review Flashcards", systemImage: "rectangle.on.rectangle.angled")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.totalFlashcardCount == 0)
        }
    }

    private var summarySection: some View {
        sectionCard(title: "Summary", systemImage: "doc.text") {
            Text(LocalizedStringKey(viewModel.summaryText))
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }

    private var topicsSection: some View {
        sectionCard(title: "Topics", systemImage: "list.bullet.rectangle") {
            if viewModel.sortedTopics.isEmpty {
                Text("Topics will appear here after study material is generated.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.sortedTopics, id: \.id) { topic in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(.blue)
                                .padding(.top, 6)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(topic.title)
                                    .font(.headline)

                                Text("\(topic.flashcards.count) flashcards • \(topic.questions.count) questions")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private var topicFlashcardsPicker: some View {
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

    private var topicQuizPicker: some View {
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

    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }
}
