import SwiftUI

struct QuizView: View {
    @Bindable var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isFinished {
                QuizResultView(viewModel: viewModel)
            } else if let question = viewModel.currentQuestion {
                progressBar
                questionCard(question)
                Spacer()
                navigationButton
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var progressBar: some View {
        VStack(spacing: 4) {
            ProgressView(value: viewModel.progress)
                .tint(.blue)

            Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func questionCard(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    optionButton(option, correctAnswer: question.correctAnswer)
                }
            }
        }
    }

    private func optionButton(_ option: String, correctAnswer: String) -> some View {
        Button {
            viewModel.selectAnswer(option)
        } label: {
            HStack {
                Text(option)
                    .multilineTextAlignment(.leading)
                Spacer()

                if viewModel.hasAnswered {
                    if option == correctAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if option == viewModel.selectedAnswer {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                } else if option == viewModel.selectedAnswer {
                    Image(systemName: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(optionBackground(option, correctAnswer: correctAnswer))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.hasAnswered)
    }

    private func optionBackground(_ option: String, correctAnswer: String) -> some ShapeStyle {
        if viewModel.hasAnswered {
            if option == correctAnswer {
                return AnyShapeStyle(.green.opacity(0.15))
            } else if option == viewModel.selectedAnswer {
                return AnyShapeStyle(.red.opacity(0.15))
            }
        } else if option == viewModel.selectedAnswer {
            return AnyShapeStyle(.blue.opacity(0.15))
        }
        return AnyShapeStyle(.fill.tertiary)
    }

    private var navigationButton: some View {
        Group {
            if !viewModel.hasAnswered {
                Button("Check Answer") {
                    withAnimation {
                        viewModel.confirmAnswer()
                    }
                }
                .disabled(viewModel.selectedAnswer == nil)
            } else {
                Button(viewModel.currentIndex + 1 < viewModel.questions.count ? "Next Question" : "See Results") {
                    withAnimation {
                        viewModel.nextQuestion()
                    }
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}
