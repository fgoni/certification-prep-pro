//
//  QuizResult.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 14/08/2024.
//

import Foundation

struct QuizResult: Identifiable, Codable {
    let id: UUID
    let date: Date
    let score: Int
    let totalQuestions: Int
    let percentage: Double
    let timeSpent: Int  // Time spent on the quiz in seconds
    let timeLimit: Int  // Time limit for the quiz in seconds

    init(score: Int, totalQuestions: Int, timeSpent: Int, timeLimit: Int) {
        self.id = UUID()
        self.date = Date()
        self.score = score
        self.totalQuestions = totalQuestions
        self.percentage = Double(score) / Double(totalQuestions) * 100
        self.timeSpent = timeSpent
        self.timeLimit = timeLimit
    }
}

