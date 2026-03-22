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
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 10)

            Circle()
                .trim(from: 0, to: Double(viewModel.scorePercentage) / 100)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: viewModel.scorePercentage)

            VStack(spacing: 2) {
                Text("\(viewModel.scorePercentage)%")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                Text("Score")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
        .frame(width: 150, height: 150)
    }

    var ringColor: Color {
        switch viewModel.scorePercentage {
        case 80...100: .green
        case 60..<80: .orange
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
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    var upgradePrompt: some View {
        NavigationLink {
            PaywallView()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("Want more questions? Upgrade to Pro")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
