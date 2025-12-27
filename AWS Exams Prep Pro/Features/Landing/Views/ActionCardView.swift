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
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(isEnabled ? .primary : .secondary)

                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor.opacity(isEnabled ? 1.0 : 0.5))
                }

                if showLock {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))

                        Text("Watch ad to unlock")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
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
