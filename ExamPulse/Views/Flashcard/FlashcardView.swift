import SwiftUI

struct FlashcardView: View {
    @Bindable var viewModel: FlashcardViewModel
    @Environment(\.dependencies) private var dependencies
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 24) {
            if viewModel.isFinished {
                sessionCompleteView
            } else if let card = viewModel.currentCard {
                sessionProgress
                flashcard(card)
                ratingControls
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Progress

private extension FlashcardView {
    var sessionProgress: some View {
        VStack(spacing: 6) {
            capsuleProgress

            HStack {
                Text("\(viewModel.currentIndex + 1) of \(viewModel.flashcards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.learnedCount) learned")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
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

// MARK: - Card

private extension FlashcardView {
    func flashcard(_ card: Flashcard) -> some View {
        ZStack {
            CardFace(label: "FRONT", text: card.front)
                .opacity(viewModel.isShowingBack ? 0 : 1)
                .rotation3DEffect(.degrees(viewModel.isShowingBack ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            CardFace(label: "BACK", text: card.back)
                .opacity(viewModel.isShowingBack ? 1 : 0)
                .rotation3DEffect(.degrees(viewModel.isShowingBack ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width / 18)))
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: dragOffset)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isShowingBack)
        .gesture(swipeGesture)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                viewModel.flip()
            }
        }
    }

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { dragOffset = $0.translation }
            .onEnded { handleSwipe($0.translation) }
    }
}

// MARK: - Rating Controls

private extension FlashcardView {
    var ratingControls: some View {
        VStack(spacing: 12) {
            if !viewModel.isShowingBack {
                Text("Tap to flip. Swipe left for Again, up for Hard, right for Easy.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                HStack(spacing: 12) {
                    ratingButton(title: "Again", rating: .again, style: .bordered, tint: .red)
                    ratingButton(title: "Hard", rating: .hard, style: .bordered, tint: .orange)
                    ratingButton(title: "Easy", rating: .easy, style: .borderedProminent, tint: .green)
                }
            }
        }
    }

    func ratingButton(
        title: String,
        rating: FlashcardViewModel.ReviewRating,
        style: some PrimitiveButtonStyle,
        tint: Color
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                submit(rating)
            }
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(style)
        .tint(tint)
    }
}

// MARK: - Session Complete

private extension FlashcardView {
    var sessionCompleteView: some View {
        VStack(spacing: 18) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 52))
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
            .controlSize(.large)
            .padding(.top, 4)

            if !dependencies.entitlementManager.isPro {
                NavigationLink {
                    PaywallView()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                        Text("Want more flashcards? Upgrade to Pro")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
    }
}

// MARK: - Swipe Handling

private extension FlashcardView {
    func handleSwipe(_ translation: CGSize) {
        let threshold: CGFloat = 110

        guard viewModel.isShowingBack else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { dragOffset = .zero }
            return
        }

        if translation.width > threshold {
            submit(.easy)
        } else if translation.width < -threshold {
            submit(.again)
        } else if translation.height < -threshold {
            submit(.hard)
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { dragOffset = .zero }
        }
    }

    func submit(_ rating: FlashcardViewModel.ReviewRating) {
        dragOffset = .zero
        viewModel.review(rating)
    }
}

// MARK: - Card Face

private struct CardFace: View {
    let label: String
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 20, y: 10)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.separator.opacity(0.3), lineWidth: 0.5)

            VStack(spacing: 16) {
                Text(label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .tracking(1.2)

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
