import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    @State private var contentVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Your ")
                    .font(.system(size: 34, weight: .bold)) +
                Text("Smart\nStudy ")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.themePurple) +
                Text("Tool for\nAny Exam")
                    .font(.system(size: 34, weight: .bold))
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.themeDark)
            .padding(.horizontal, 4)

            Spacer().frame(height: 40)

            ZStack {
                GradientBlob(size: 240)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(height: 260)

            Spacer()

            Text("Get instant help and support\nwith any exam or study material")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 24)

            Button {
                onContinue()
            } label: {
                HStack(spacing: 8) {
                    Text("Get started")
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
            }
            .buttonStyle(.outline)
        }
        .padding(24)
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 16)
        .themeCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(AppAnimation.content) {
                contentVisible = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView {}
    }
}
