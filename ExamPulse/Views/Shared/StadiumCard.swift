import SwiftUI

struct StadiumCard: ViewModifier {
    var padding: CGFloat = 18
    var cornerRadius: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: stadium)
            .overlay { stadium.strokeBorder(.separator.opacity(0.35), lineWidth: 0.5) }
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    private var stadium: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
}

extension View {
    func stadiumCard(padding: CGFloat = 18, cornerRadius: CGFloat = 22) -> some View {
        modifier(StadiumCard(padding: padding, cornerRadius: cornerRadius))
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
            .background(color.opacity(0.14), in: Capsule())
            .foregroundStyle(color)
    }
}

// MARK: - Gradient Accent Header

struct GradientHero: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var gradient: [Color] = [.blue, .purple]

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 52, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
}

// MARK: - Icon Circle

struct IconCircle: View {
    let systemImage: String
    let color: Color
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.12), in: Circle())
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
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.tertiaryLabel)
        }
    }
}

private extension ShapeStyle where Self == Color {
    static var tertiaryLabel: Color { Color(uiColor: .tertiaryLabel) }
}
