import Foundation
import Combine

/// Protocol defining quiz attempt limit management capabilities
public protocol QuizLimitProviderProtocol: ObservableObject {
    /// The number of remaining quiz attempts available to the user
    var remainingAttempts: Int { get }

    /// Checks if the user can start a new quiz
    /// - Returns: true if user has remaining attempts, false otherwise
    func canStartQuiz() -> Bool

    /// Consumes one quiz attempt
    /// Should be called when user starts a quiz
    func useAttempt()

    /// Adds one quiz attempt (e.g., after watching an ad)
    func addAttempt()

    /// Returns a string representing the time until the daily quota resets
    /// Format: "HH:MM"
    func timeUntilReset() -> String
}
