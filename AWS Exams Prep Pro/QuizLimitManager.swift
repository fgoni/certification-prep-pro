import Foundation

class QuizLimitManager: ObservableObject {
    static let shared = QuizLimitManager()
    
    private let userDefaults = UserDefaults.standard
    private let dailyLimit = 3
    private var resetCheckTimer: Timer?
    
    @Published var remainingAttempts: Int
    
    private init() {
        // Load saved value or initialize with default
        remainingAttempts = userDefaults.integer(forKey: "remainingAttempts")
        
        // Set up initial reset check
        checkAndResetIfNeeded()
        
        // Set up periodic reset check (every hour)
        resetCheckTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkAndResetIfNeeded()
        }
    }
    
    deinit {
        resetCheckTimer?.invalidate()
    }
    
    private func checkAndResetIfNeeded() {
        if shouldResetLimits() {
            resetLimits()
        }
    }
    
    private func shouldResetLimits() -> Bool {
        guard let lastResetDate = userDefaults.object(forKey: "lastResetDate") as? Date else {
            return true
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's been a day since last reset
        if let daysSinceReset = calendar.dateComponents([.day], from: lastResetDate, to: now).day {
            return daysSinceReset >= 1
        }
        
        return true
    }
    
    private func resetLimits() {
        remainingAttempts = dailyLimit
        userDefaults.set(remainingAttempts, forKey: "remainingAttempts")
        userDefaults.set(Date(), forKey: "lastResetDate")
    }
    
    func canStartQuiz() -> Bool {
        return remainingAttempts > 0
    }
    
    func useAttempt() {
        if remainingAttempts > 0 {
            remainingAttempts -= 1
            userDefaults.set(remainingAttempts, forKey: "remainingAttempts")
        }
    }
    
    func addAttempt() {
        remainingAttempts += 1
        userDefaults.set(remainingAttempts, forKey: "remainingAttempts")
    }
    
    func timeUntilReset() -> String {
        guard let lastResetDate = userDefaults.object(forKey: "lastResetDate") as? Date else {
            return "Unknown"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate next reset date (1 day from last reset)
        guard let nextResetDate = calendar.date(byAdding: .day, value: 1, to: lastResetDate) else {
            return "Unknown"
        }
        
        let components = calendar.dateComponents([.hour, .minute], from: now, to: nextResetDate)
        
        if let hours = components.hour, let minutes = components.minute {
            return "\(hours)h \(minutes)m"
        }
        
        return "Unknown"
    }
} 