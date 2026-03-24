import SwiftUI

struct SplashView: View {
    @State private var blobScale: CGFloat = 0.6
    @State private var blobOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 16
    @State private var screenOpacity: Double = 1

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.themeCanvas.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    blob
                    pulseIcon
                }
                .frame(width: 200, height: 200)

                VStack(spacing: 6) {
                    Text("ExamPulse")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.themeDark)

                    Text("Study smarter, ace your exams")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)

                Spacer()
                Spacer()
            }
        }
        .opacity(screenOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                blobScale = 1.0
                blobOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                titleOpacity = 1.0
                titleOffset = 0
            }

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.8))
                await runExitAnimation()
            }
        }
    }

    @MainActor
    private func runExitAnimation() async {
        withAnimation(AppAnimation.splashExit) {
            screenOpacity = 0
            blobScale = 0.92
            blobOpacity = 0
            titleOpacity = 0
            titleOffset = 8
        }
        try? await Task.sleep(for: .seconds(0.42))
        onFinished()
    }

    private var blob: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.themePeach.opacity(0.9),
                            Color.themePurple.opacity(0.6),
                            Color.themePurple
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 180, height: 180)
                .blur(radius: 24)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.themePeach.opacity(0.5),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 5,
                        endRadius: 80
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 16)
        }
        .scaleEffect(blobScale)
        .opacity(blobOpacity)
    }

    private var pulseIcon: some View {
        Image(systemName: "waveform.path.ecg")
            .font(.system(size: 42, weight: .medium))
            .foregroundStyle(.white.opacity(0.9))
            .scaleEffect(blobScale)
            .opacity(blobOpacity)
    }
}
