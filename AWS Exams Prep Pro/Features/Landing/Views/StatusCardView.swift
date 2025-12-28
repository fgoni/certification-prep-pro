import SwiftUI

/// Status card types with associated colors
enum StatusType {
    case credits
    case timer

    var backgroundColor: Color {
        switch self {
        case .credits:
            return AppTheme.Colors.creditsCardBackground
        case .timer:
            return AppTheme.Colors.timerCardBackground
        }
    }

    var iconColor: Color {
        switch self {
        case .credits:
            return AppTheme.Colors.creditsIconColor
        case .timer:
            return AppTheme.Colors.timerIconColor
        }
    }

    var iconBackground: Color {
        switch self {
        case .credits:
            return AppTheme.Colors.creditsIconBackground
        case .timer:
            return AppTheme.Colors.timerIconBackground
        }
    }

    var textColor: Color {
        switch self {
        case .credits:
            return AppTheme.Colors.creditsCardText
        case .timer:
            return AppTheme.Colors.timerCardText
        }
    }
}

/// A reusable card component for displaying status information with colored backgrounds
/// Used for credits counter and timer display
struct StatusCardView: View {
    let icon: String
    let type: StatusType
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            HStack(spacing: 12) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(type.iconBackground)
                        .frame(width: 28, height: 28)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(type.iconColor)
                }

                Text(label.uppercased())
                    .font(AppTheme.Typography.statusCardLabel)
                    .tracking(0.4)
                    .foregroundColor(type.iconColor)

                Spacer()
            }

            Text(value)
                .font(AppTheme.Typography.statusCardValue)
                .tracking(0.2)
                .foregroundColor(type.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(type.backgroundColor)
        .cornerRadius(16)
    }
}

#Preview("Light Mode") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            StatusCardView(
                icon: "bolt.fill",
                type: .credits,
                label: "Credits",
                value: "0 of 3 Remaining"
            )

            StatusCardView(
                icon: "clock.fill",
                type: .timer,
                label: "Next Refill",
                value: "12:36"
            )
        }
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            StatusCardView(
                icon: "bolt.fill",
                type: .credits,
                label: "Credits",
                value: "0 of 3 Remaining"
            )

            StatusCardView(
                icon: "clock.fill",
                type: .timer,
                label: "Next Refill",
                value: "12:36"
            )
        }
    }
    .padding()
    .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
    .preferredColorScheme(.dark)
}
