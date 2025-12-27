import Foundation

/// Core quiz question model
/// Single source of truth for quiz data
struct QuizQuestion: Identifiable, Decodable {
    let id: String
    let questionText: String
    let options: [String]
    let correctAnswers: [String]
    let explanation: String?
    let category: String
}
