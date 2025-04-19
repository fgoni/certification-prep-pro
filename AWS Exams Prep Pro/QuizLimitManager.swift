import Foundation
import SwiftUI

class QuizLimitManager: ObservableObject {
    static let shared = QuizLimitManager()
    
    @Published private(set) var remainingAttempts: Int
    private let maxAttempts = 3
    private let lastResetDateKey = "lastResetDate"
    private let remainingAttemptsKey = "remainingAttempts"
    
    private init() {
        // Load the remaining attempts from UserDefaults
        self.remainingAttempts = UserDefaults.standard.integer(forKey: remainingAttemptsKey)
        
        // If this is the first time or the value is 0, set it to max attempts
        if self.remainingAttempts == 0 {
            self.remainingAttempts = maxAttempts
            UserDefaults.standard.set(maxAttempts, forKey: remainingAttemptsKey)
        }
        
        // Check if we need to reset the limits
        if shouldResetLimits() {
            resetLimits()
        }
    }
    
    private func shouldResetLimits() -> Bool {
        guard let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date else {
            return true
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's a new day
        return !calendar.isDate(lastResetDate, inSameDayAs: now)
    }
    
    private func resetLimits() {
        remainingAttempts = maxAttempts
        UserDefaults.standard.set(maxAttempts, forKey: remainingAttemptsKey)
        UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
    }
    
    func canStartQuiz() -> Bool {
        return remainingAttempts > 0
    }
    
    func useAttempt() {
        guard remainingAttempts > 0 else { return }
        remainingAttempts -= 1
        UserDefaults.standard.set(remainingAttempts, forKey: remainingAttemptsKey)
    }
    
    func addAttempt() {
        remainingAttempts += 1
        UserDefaults.standard.set(remainingAttempts, forKey: remainingAttemptsKey)
    }
    
    func timeUntilReset() -> String {
        let calendar = Calendar.current
        let now = Date()
        let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date ?? now
        
        // Get the start of the next day
        let nextDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: lastResetDate)!)
        
        // Calculate the time difference
        let components = calendar.dateComponents([.hour, .minute], from: now, to: nextDay)
        
        return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
    }
} 