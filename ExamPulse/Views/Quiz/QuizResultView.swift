import SwiftUI

struct QuizResultView: View {
    @Bindable var viewModel: QuizViewModel
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        VStack(spacing: 24) {
            scoreRing
            resultMessage
            scoreDetail
            retryButton

            if !dependencies.entitlementManager.isPro {
                upgradePrompt
            }
        }
        .padding()
    }
}

// MARK: - Score Ring

private extension QuizResultView {
    var scoreRing: some View {
        ScoreRing(
            value: Double(viewModel.scorePercentage) / 100,
            trackColor: .themePurple.opacity(0.1),
            fillColor: ringColor,
            size: 150,
            lineWidth: 10
        )
    }

    var ringColor: Color {
        switch viewModel.scorePercentage {
        case 80...100: .green
        case 60..<80: .themePeach
        default: .red
        }
    }
}

// MARK: - Text Content

private extension QuizResultView {
    var resultMessage: some View {
        Text(message)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.themeDark)
            .multilineTextAlignment(.center)
    }

    var message: String {
        switch viewModel.scorePercentage {
        case 90...100: "Excellent! You've mastered this topic!"
        case 70..<90: "Great job! Almost there."
        case 50..<70: "Good effort. Keep studying!"
        default: "Keep practicing, you'll get there!"
        }
    }

    var scoreDetail: some View {
        Text("\(viewModel.correctCount) out of \(viewModel.questions.count) correct")
            .foregroundStyle(.secondary)
    }
}

// MARK: - Actions

private extension QuizResultView {
    var retryButton: some View {
        Button("Try Again") {
            viewModel.restart()
        }
        .buttonStyle(.primary)
    }

    var upgradePrompt: some View {
        NavigationLink {
            PaywallView()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.themePurple)
                Text("Want more questions? Upgrade to Pro")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
