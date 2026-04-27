//
//  QuizManager.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 14/08/2024.
//

import Foundation

class QuizResultsManager {
    static let shared = QuizResultsManager()

    private let resultsKey = "quizResults"

    func saveResult(_ result: QuizResult) {
        var results = fetchResults()
        results.append(result)
        if let encoded = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(encoded, forKey: resultsKey)
        }
    }

    func fetchResults() -> [QuizResult] {
        if let data = UserDefaults.standard.data(forKey: resultsKey),
           let results = try? JSONDecoder().decode([QuizResult].self, from: data) {
            return results
        }
        return []
    }

    /// Consecutive-day streak ending at today (or yesterday — grace period of one day).
    /// Returns 0 if there's no activity in the last 2 calendar days.
    func currentStreak(now: Date = Date(), calendar: Calendar = .current) -> Int {
        let results = fetchResults()
        guard !results.isEmpty else { return 0 }

        let activeDays: Set<Date> = Set(results.map { calendar.startOfDay(for: $0.date) })
        let today = calendar.startOfDay(for: now)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }

        // Anchor: today if there's activity, otherwise yesterday (grace), else 0.
        var anchor: Date
        if activeDays.contains(today) {
            anchor = today
        } else if activeDays.contains(yesterday) {
            anchor = yesterday
        } else {
            return 0
        }

        var streak = 1
        while let prev = calendar.date(byAdding: .day, value: -1, to: anchor),
              activeDays.contains(prev) {
            streak += 1
            anchor = prev
        }
        return streak
    }
}
