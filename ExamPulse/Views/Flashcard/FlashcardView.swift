import SwiftUI

struct FlashcardView: View {
    @Bindable var viewModel: FlashcardViewModel

    var body: some View {
        VStack(spacing: 24) {
            if viewModel.isFinished {
                finishedView
            } else if let card = viewModel.currentCard {
                progressBar
                cardView(card)
                actionButtons
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

            HStack {
                Text("\(viewModel.currentIndex + 1) of \(viewModel.flashcards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.learnedCount) learned")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }

    private func cardView(_ card: Flashcard) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.quaternary, lineWidth: 1)

            VStack(spacing: 12) {
                Text(viewModel.isShowingBack ? "Answer" : "Question")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(viewModel.isShowingBack ? card.back : card.front)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(24)
        }
        .frame(maxHeight: 300)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                viewModel.flip()
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !viewModel.isShowingBack {
                Text("Tap card to reveal answer")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 16) {
                    Button {
                        viewModel.markNotLearned()
                    } label: {
                        Label("Still Learning", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Button {
                        viewModel.markLearned()
                    } label: {
                        Label("Got It", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Session Complete!")
                .font(.title2)
                .fontWeight(.bold)

            Text("\(viewModel.learnedCount) of \(viewModel.flashcards.count) cards learned")
                .foregroundStyle(.secondary)

            Button("Study Again") {
                viewModel.restart()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
}
