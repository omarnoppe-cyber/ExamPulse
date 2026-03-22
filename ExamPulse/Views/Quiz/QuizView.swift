import SwiftUI

struct QuizView: View {
    @Bindable var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isFinished {
                QuizResultView(viewModel: viewModel)
            } else if let question = viewModel.currentQuestion {
                progressBar
                ScrollView {
                    VStack(spacing: 20) {
                        questionCard(question)

                        if viewModel.hasAnswered {
                            answerFeedback(question)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)
                navigationButton
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var progressBar: some View {
        VStack(spacing: 8) {
            ProgressView(value: viewModel.progress)
                .tint(.blue)

            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Score \(viewModel.correctCount)/\(viewModel.questions.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func questionCard(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.prompt)
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
            guard !viewModel.hasAnswered else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectAnswer(option)
                viewModel.confirmAnswer()
            }
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

    private func answerFeedback(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(
                viewModel.selectedAnswer == question.correctAnswer ? "Correct" : "Correct Answer",
                systemImage: viewModel.selectedAnswer == question.correctAnswer
                    ? "checkmark.circle.fill"
                    : "info.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(viewModel.selectedAnswer == question.correctAnswer ? .green : .blue)

            VStack(alignment: .leading, spacing: 8) {
                Text("Answer")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(question.correctAnswer)
                    .fontWeight(.medium)
            }

            if !question.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explanation")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text(question.explanation)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
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
            if viewModel.hasAnswered {
                Button(viewModel.currentIndex + 1 < viewModel.questions.count ? "Next Question" : "See Results") {
                    withAnimation {
                        viewModel.nextQuestion()
                    }
                }
            } else {
                Text("Select an answer to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
