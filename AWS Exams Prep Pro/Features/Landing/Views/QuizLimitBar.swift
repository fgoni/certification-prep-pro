import SwiftUI

/// Displays current quiz attempt count and time until daily reset
struct QuizLimitBar: View {
    @StateObject private var quizLimitManager = QuizLimitManager.shared

    var body: some View {
        HStack(spacing: 12) {
            StatusCardView(
                icon: "bolt.fill",
                iconColor: .white,
                label: "Credits",
                value: "\(quizLimitManager.remainingAttempts) of 3 Remaining",
                backgroundColor: Color.orange
            )

            StatusCardView(
                icon: "clock.fill",
                iconColor: .white,
                label: "Next Refill",
                value: quizLimitManager.timeUntilReset(),
                backgroundColor: Color.blue
            )
        }
    }
}

#Preview {
    QuizLimitBar()
}
