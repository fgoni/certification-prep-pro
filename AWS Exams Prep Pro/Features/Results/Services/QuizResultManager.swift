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
    
}
