import SwiftUI

struct FlashcardView: View {
    @Bindable var viewModel: FlashcardViewModel
    @State private var dragOffset: CGSize = .zero

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
            FlashcardFaceView(
                title: "Front",
                text: card.front
            )
            .opacity(viewModel.isShowingBack ? 0 : 1)
            .rotation3DEffect(
                .degrees(viewModel.isShowingBack ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )

            FlashcardFaceView(
                title: "Back",
                text: card.back
            )
            .opacity(viewModel.isShowingBack ? 1 : 0)
            .rotation3DEffect(
                .degrees(viewModel.isShowingBack ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width / 18)))
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: dragOffset)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isShowingBack)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    handleSwipe(value.translation)
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                viewModel.flip()
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !viewModel.isShowingBack {
                Text("Tap to flip. Swipe left for Again, up for Hard, right for Easy.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            submit(.again)
                        }
                    } label: {
                        Text("Again")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            submit(.hard)
                        }
                    } label: {
                        Text("Hard")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            submit(.easy)
                        }
                    } label: {
                        Text("Easy")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
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

    private func handleSwipe(_ translation: CGSize) {
        let horizontalThreshold: CGFloat = 110
        let upwardThreshold: CGFloat = -110

        if !viewModel.isShowingBack {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                dragOffset = .zero
            }
            return
        }

        if translation.width > horizontalThreshold {
            submit(.easy)
        } else if translation.width < -horizontalThreshold {
            submit(.again)
        } else if translation.height < upwardThreshold {
            submit(.hard)
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                dragOffset = .zero
            }
        }
    }

    private func submit(_ rating: FlashcardViewModel.ReviewRating) {
        dragOffset = .zero
        viewModel.review(rating)
    }
}

private struct FlashcardFaceView: View {
    let title: String
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 16, y: 8)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)

            VStack(spacing: 16) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(28)
        }
    }
}
