import Foundation
import SwiftUI
import Combine

/// Manages quiz attempt limits and daily reset logic
/// Conforms to QuizLimitProviderProtocol for decoupling
final class QuizLimitManager: QuizLimitProviderProtocol {
    // MARK: - Singleton
    static let shared = QuizLimitManager()

    // MARK: - Published Properties
    @Published private(set) var remainingAttempts: Int = 0
    @Published private(set) var timeUntilResetDisplay: String = "00:00"

    // MARK: - Properties
    private let configuration: QuizLimitConfiguration
    private var timer: Timer?

    // MARK: - Initialization
    private init(configuration: QuizLimitConfiguration = .default) {
        self.configuration = configuration
        setupInitialState()
        startTimer()
    }

    // MARK: - Private Methods
    private func setupInitialState() {
        // Load the remaining attempts from UserDefaults
        remainingAttempts = UserDefaults.standard.integer(forKey: configuration.remainingAttemptsKey)

        // If this is the first time or the value is 0, set it to max attempts
        if remainingAttempts == 0 {
            remainingAttempts = configuration.maxAttempts
            UserDefaults.standard.set(configuration.maxAttempts, forKey: configuration.remainingAttemptsKey)
        }

        // Check if we need to reset the limits
        if shouldResetLimits() {
            resetLimits()
        }
    }

    private func shouldResetLimits() -> Bool {
        guard let lastResetDate = UserDefaults.standard.object(forKey: configuration.lastResetDateKey) as? Date else {
            return true
        }

        let calendar = Calendar.current
        let now = Date()

        // Check if it's a new day
        return !calendar.isDate(lastResetDate, inSameDayAs: now)
    }

    private func resetLimits() {
        remainingAttempts = configuration.maxAttempts
        UserDefaults.standard.set(configuration.maxAttempts, forKey: configuration.remainingAttemptsKey)
        UserDefaults.standard.set(Date(), forKey: configuration.lastResetDateKey)
    }

    // MARK: - QuizLimitProviderProtocol Implementation
    func canStartQuiz() -> Bool {
        return remainingAttempts > 0
    }

    func useAttempt() {
        guard remainingAttempts > 0 else { return }
        remainingAttempts -= 1
        UserDefaults.standard.set(remainingAttempts, forKey: configuration.remainingAttemptsKey)
    }

    func addAttempt() {
        remainingAttempts += 1
        UserDefaults.standard.set(remainingAttempts, forKey: configuration.remainingAttemptsKey)
    }

    func timeUntilReset() -> String {
        let calendar = Calendar.current
        let now = Date()
        let lastResetDate = UserDefaults.standard.object(forKey: configuration.lastResetDateKey) as? Date ?? now

        // Get the start of the next day
        let nextDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: lastResetDate)!)

        // Calculate the time difference
        let components = calendar.dateComponents([.hour, .minute], from: now, to: nextDay)

        return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
    }

    private func startTimer() {
        // Update immediately
        timeUntilResetDisplay = timeUntilReset()

        // Set up timer to update every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timeUntilResetDisplay = self?.timeUntilReset() ?? "00:00"
        }
    }
}
