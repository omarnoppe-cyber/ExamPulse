import SwiftUI

struct QuizResultView: View {
    @Bindable var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 24) {
            scoreCircle

            Text(scoreMessage)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            Text("\(viewModel.correctCount) out of \(viewModel.questions.count) correct")
                .foregroundStyle(.secondary)

            Button("Try Again") {
                viewModel.restart()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }

    private var scoreCircle: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 12)

            Circle()
                .trim(from: 0, to: Double(viewModel.scorePercentage) / 100)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: viewModel.scorePercentage)

            VStack(spacing: 2) {
                Text("\(viewModel.scorePercentage)%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 140, height: 140)
    }

    private var scoreMessage: String {
        switch viewModel.scorePercentage {
        case 90...100: return "Excellent! You've mastered this topic!"
        case 70..<90: return "Great job! Almost there."
        case 50..<70: return "Good effort. Keep studying!"
        default: return "Keep practicing, you'll get there!"
        }
    }

    private var scoreColor: Color {
        switch viewModel.scorePercentage {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}
