import SwiftUI

struct QuizView: View {
    @Bindable var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isFinished {
                QuizResultView(viewModel: viewModel)
            } else if let question = viewModel.currentQuestion {
                quizProgress
                ScrollView {
                    VStack(spacing: 20) {
                        questionSection(question)
                        if viewModel.hasAnswered {
                            feedbackSection(question)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                Spacer(minLength: 0)
                bottomAction
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Progress

private extension QuizView {
    var quizProgress: some View {
        VStack(spacing: 8) {
            capsuleProgress

            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Score \(viewModel.correctCount)/\(viewModel.questions.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var capsuleProgress: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.blue.opacity(0.12))
                Capsule()
                    .fill(Color.blue.gradient)
                    .frame(width: geo.size.width * viewModel.progress)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
            }
        }
        .frame(height: 6)
        .clipShape(Capsule())
    }
}

// MARK: - Question

private extension QuizView {
    func questionSection(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.prompt)
                .font(.title3)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    optionPill(option, correctAnswer: question.correctAnswer)
                }
            }
        }
    }

    func optionPill(_ option: String, correctAnswer: String) -> some View {
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
                optionIndicator(option, correctAnswer: correctAnswer)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(optionFill(option, correctAnswer: correctAnswer), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(optionBorder(option, correctAnswer: correctAnswer), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.hasAnswered)
    }

    @ViewBuilder
    func optionIndicator(_ option: String, correctAnswer: String) -> some View {
        if viewModel.hasAnswered {
            if option == correctAnswer {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            } else if option == viewModel.selectedAnswer {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
            }
        } else if option == viewModel.selectedAnswer {
            Image(systemName: "circle.fill").font(.caption).foregroundStyle(.blue)
        }
    }

    func optionFill(_ option: String, correctAnswer: String) -> some ShapeStyle {
        if viewModel.hasAnswered {
            if option == correctAnswer { return AnyShapeStyle(.green.opacity(0.1)) }
            if option == viewModel.selectedAnswer { return AnyShapeStyle(.red.opacity(0.1)) }
        } else if option == viewModel.selectedAnswer {
            return AnyShapeStyle(.blue.opacity(0.1))
        }
        return AnyShapeStyle(.fill.tertiary)
    }

    func optionBorder(_ option: String, correctAnswer: String) -> some ShapeStyle {
        if viewModel.hasAnswered {
            if option == correctAnswer { return AnyShapeStyle(.green.opacity(0.3)) }
            if option == viewModel.selectedAnswer { return AnyShapeStyle(.red.opacity(0.3)) }
        } else if option == viewModel.selectedAnswer {
            return AnyShapeStyle(.blue.opacity(0.3))
        }
        return AnyShapeStyle(.separator.opacity(0.2))
    }
}

// MARK: - Feedback

private extension QuizView {
    func feedbackSection(_ question: Question) -> some View {
        let isCorrect = viewModel.selectedAnswer == question.correctAnswer
        return VStack(alignment: .leading, spacing: 14) {
            Label(
                isCorrect ? "Correct" : "Correct Answer",
                systemImage: isCorrect ? "checkmark.circle.fill" : "info.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(isCorrect ? .green : .blue)

            labeledBlock(label: "Answer") {
                Text(question.correctAnswer).fontWeight(.medium)
            }

            if !question.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                labeledBlock(label: "Explanation") {
                    Text(question.explanation)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .stadiumCard()
    }

    func labeledBlock<C: View>(label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
            content()
        }
    }
}

// MARK: - Bottom Action

private extension QuizView {
    var bottomAction: some View {
        Group {
            if viewModel.hasAnswered {
                Button(viewModel.currentIndex + 1 < viewModel.questions.count ? "Next Question" : "See Results") {
                    withAnimation { viewModel.nextQuestion() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Text("Select an answer to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
