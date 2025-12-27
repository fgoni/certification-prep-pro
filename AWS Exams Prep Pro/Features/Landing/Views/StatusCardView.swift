import SwiftUI

/// A reusable card component for displaying status information with colored backgrounds
/// Used for credits counter and timer display
struct StatusCardView: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            StatusCardView(
                icon: "bolt.fill",
                iconColor: .white,
                label: "Credits",
                value: "3 of 3 Remaining",
                backgroundColor: Color.orange
            )

            StatusCardView(
                icon: "clock.fill",
                iconColor: .white,
                label: "Next Refill",
                value: "12:36",
                backgroundColor: Color.blue
            )
        }
    }
    .padding()
}
