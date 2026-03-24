import SwiftUI

// MARK: - Theme

/// Shared animation curves for consistent, smooth motion across the app.
enum AppAnimation {
    /// Root flow: splash → onboarding → paywall → main tabs
    static let root = Animation.spring(response: 0.52, dampingFraction: 0.86, blendDuration: 0)
    /// Tab bar selection
    static let tab = Animation.easeInOut(duration: 0.32)
    /// Screen content (cards, lists)
    static let content = Animation.spring(response: 0.45, dampingFraction: 0.92, blendDuration: 0)
    /// Splash exit (fade / scale)
    static let splashExit = Animation.easeInOut(duration: 0.4)
}

enum Theme {
    static let purple = Color(hex: 0x6A68DF)
    static let peach = Color(hex: 0xEFB995)
    static let dark = Color(hex: 0x2E2C2D)

    static let canvas = Color(light: Color(hex: 0xF4F3F8), dark: Color(hex: 0x111113))
    static let surface = Color(light: .white, dark: Color(hex: 0x1C1C1E))
    static let surfaceElevated = Color(light: Color(hex: 0xF0EFF4), dark: Color(hex: 0x2A2A2E))
}

private extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Semantic Colors

extension ShapeStyle where Self == Color {
    static var themePurple: Color { Theme.purple }
    static var themePeach: Color { Theme.peach }
    static var themeDark: Color { Theme.dark }
    static var themeSurface: Color { Theme.surface }
    static var themeCanvas: Color { Theme.canvas }
    static var themeSurfaceElevated: Color { Theme.surfaceElevated }
}

// MARK: - Soft Card

struct SoftCard: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themeSurface, in: shape)
            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
}

extension View {
    func softCard(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        modifier(SoftCard(padding: padding, cornerRadius: cornerRadius))
    }

    func themeCanvas() -> some View {
        background(Color.themeCanvas.ignoresSafeArea())
    }
}

// MARK: - Status Pill

struct StatusPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
            .foregroundStyle(color)
    }
}

// MARK: - Icon Circle

struct IconCircle: View {
    let systemImage: String
    let color: Color
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.38, weight: .medium))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
    }
}

// MARK: - Disclosure Row

struct DisclosureRow<Icon: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        HStack(spacing: 14) {
            icon()
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.themeDark)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.quaternary)
        }
    }
}

// MARK: - Score Ring

struct ScoreRing: View {
    let value: Double
    var trackColor: Color = .themePurple.opacity(0.1)
    var fillColor: Color = .themePurple
    var size: CGFloat = 64
    var lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            Circle().stroke(trackColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(value, 0), 1))
                .stroke(fillColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(value * 100))%")
                .font(.system(size: size * 0.26, weight: .bold, design: .rounded))
                .foregroundStyle(.themeDark)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Gradient Blob (onboarding orb)

struct GradientBlob: View {
    var size: CGFloat = 220

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.themePeach, .themePurple.opacity(0.7), .themePurple],
                        center: .center,
                        startRadius: size * 0.05,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .blur(radius: size * 0.12)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: String? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.themeDark)
            Spacer()
            if let action {
                Text(action)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.themePurple, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - Outline Button Style

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(.themeDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule().strokeBorder(Color.themeDark.opacity(0.15), lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == OutlineButtonStyle {
    static var outline: OutlineButtonStyle { OutlineButtonStyle() }
}

// Backward compat
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var accent: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// Backward compat for stadiumCard
extension View {
    func stadiumCard(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        softCard(padding: padding, cornerRadius: cornerRadius)
    }
}

// Backward compat color aliases
extension ShapeStyle where Self == Color {
    static var themeAccent: Color { Theme.purple }
    static var themePink: Color { Theme.peach }
    static var themeLime: Color { Theme.purple }
    static var themeLavender: Color { Theme.purple }
}

// Backward compat
struct HeroBanner<Content: View>: View {
    var color: Color = .themePurple
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct PastelCard<Content: View>: View {
    let color: Color
    var cornerRadius: CGFloat = 20
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct GradientHero: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var gradient: [Color] = [.themePurple, .themePeach]

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 48, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.themePurple)

            Text(title).font(.title).fontWeight(.bold).multilineTextAlignment(.center).foregroundStyle(.themeDark)
            Text(subtitle).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
}

// Backward compat
struct TileCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themeSurface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}
