import Foundation

/// Configuration for quiz limit manager
/// Separates configuration from implementation
public struct QuizLimitConfiguration {
    let maxAttempts: Int
    let lastResetDateKey: String
    let remainingAttemptsKey: String

    /// Default configuration
    static let `default` = QuizLimitConfiguration(
        maxAttempts: 3,
        lastResetDateKey: "lastResetDate",
        remainingAttemptsKey: "remainingAttempts"
    )
}
