import SwiftUI

/// Displays current quiz attempt count and time until daily reset
struct QuizLimitBar: View {
    @StateObject private var quizLimitManager = QuizLimitManager.shared

    var body: some View {
        HStack(spacing: 12) {
            StatusCardView(
                icon: "bolt.fill",
                type: .credits,
                label: "Number of free quizzes remaining",
                value: "\(quizLimitManager.remainingAttempts)/3"
            )

            StatusCardView(
                icon: "clock.fill",
                type: .timer,
                label: "Time until next free quiz",
                value: quizLimitManager.timeUntilReset()
            )
        }
    }
}

#Preview {
    QuizLimitBar()
}
