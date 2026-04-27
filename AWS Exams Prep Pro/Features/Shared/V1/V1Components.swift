import SwiftUI

// MARK: - V1Ring
/// Animated progress ring used on Home (52pt) and Result (180pt).
struct V1Ring: View {
    let pct: Double
    var size: CGFloat = 52
    var stroke: CGFloat = 6
    var color: Color = AppTheme.V1.Colors.accent
    var animate: Bool = true

    @State private var animPct: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.V1.Colors.hair, lineWidth: stroke)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(animPct, 0), 100) / 100))
                .stroke(color, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            if animate {
                withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1.0)) {
                    animPct = pct
                }
            } else {
                animPct = pct
            }
        }
    }
}

// MARK: - V1Card
/// Card container with hairline border, rounded corners, and standard padding.
struct V1Card<Content: View>: View {
    var padding: CGFloat = 14
    var radius: CGFloat = AppTheme.V1.Metrics.radiusLg
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(AppTheme.V1.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
            )
    }
}

// MARK: - V1Pill
struct V1Pill: View {
    let text: String
    var color: Color = AppTheme.V1.Colors.muted
    var background: Color = AppTheme.V1.Colors.hair
    var fontSize: CGFloat = 10

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: fontSize, weight: .bold))
            .tracking(0.4)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(background)
            )
    }
}

// MARK: - V1SectionLabel
struct V1SectionLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(AppTheme.V1.Typography.captionEmphasis)
            .tracking(0.6)
            .foregroundStyle(AppTheme.V1.Colors.muted)
    }
}

// MARK: - V1Chevron
struct V1Chevron: View {
    var color: Color = AppTheme.V1.Colors.muted
    var size: CGFloat = 8

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 1, y: 1))
            path.addLine(to: CGPoint(x: 7, y: 7))
            path.addLine(to: CGPoint(x: 1, y: 13))
        }
        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size * 1.75)
    }
}

// MARK: - V1Button
enum V1ButtonStyle {
    case primary
    case secondary
}

struct V1Button: View {
    let title: String
    var style: V1ButtonStyle = .primary
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.V1.Typography.actionLabel)
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                        .fill(background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                        .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
                )
        }
        .disabled(disabled)
        .buttonStyle(.plain)
    }

    private var background: Color {
        if disabled { return AppTheme.V1.Colors.hair }
        switch style {
        case .primary: return AppTheme.V1.Colors.accent
        case .secondary: return AppTheme.V1.Colors.card
        }
    }

    private var foreground: Color {
        if disabled { return AppTheme.V1.Colors.muted }
        switch style {
        case .primary: return .white
        case .secondary: return AppTheme.V1.Colors.ink
        }
    }

    private var borderColor: Color {
        AppTheme.V1.Colors.hair
    }
}

// MARK: - V1BackButton
struct V1BackButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Path { path in
                    path.move(to: CGPoint(x: 5, y: 1))
                    path.addLine(to: CGPoint(x: 1, y: 5.5))
                    path.addLine(to: CGPoint(x: 5, y: 10))
                }
                .stroke(AppTheme.V1.Colors.muted,
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 6, height: 11)
                Text(title)
                    .font(AppTheme.V1.Typography.label)
                    .foregroundStyle(AppTheme.V1.Colors.muted)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - V1ScreenBackground
/// Soft purple-tinted background matching the prototype body gradient.
struct V1ScreenBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        AppTheme.V1.Colors.bg
            .ignoresSafeArea()
    }
}
