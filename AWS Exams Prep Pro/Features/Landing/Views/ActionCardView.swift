import SwiftUI

/// A reusable card component for interactive actions (quiz buttons, navigation links)
/// Supports enabled/disabled states with lock indicator
struct ActionCardView: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let isEnabled: Bool
    let showLock: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(AppTheme.Typography.actionCardTitle)
                            .foregroundColor(isEnabled ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)

                        Text(subtitle)
                            .font(AppTheme.Typography.actionCardSubtitle)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isEnabled ? iconColor : AppTheme.Colors.textSecondary.opacity(0.5))
                }

                if showLock {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))

                        Text("Watch ad to unlock")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.actionCardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.actionCardBorder, lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Enabled") {
    VStack(spacing: 12) {
        ActionCardView(
            title: "Full Quiz",
            subtitle: "65 Questions • 40 Minutes",
            icon: "arrow.right.circle.fill",
            iconColor: .blue,
            isEnabled: true,
            showLock: false,
            action: { }
        )

        ActionCardView(
            title: "Quick Quiz",
            subtitle: "20 Questions • 12 Minutes",
            icon: "arrow.right.circle.fill",
            iconColor: .blue,
            isEnabled: true,
            showLock: false,
            action: { }
        )
    }
    .padding()
}

#Preview("Disabled") {
    VStack(spacing: 12) {
        ActionCardView(
            title: "Full Quiz",
            subtitle: "65 Questions • 40 Minutes",
            icon: "arrow.right.circle.fill",
            iconColor: .blue,
            isEnabled: false,
            showLock: true,
            action: { }
        )

        ActionCardView(
            title: "Quick Quiz",
            subtitle: "20 Questions • 12 Minutes",
            icon: "arrow.right.circle.fill",
            iconColor: .blue,
            isEnabled: false,
            showLock: true,
            action: { }
        )
    }
    .padding()
}
