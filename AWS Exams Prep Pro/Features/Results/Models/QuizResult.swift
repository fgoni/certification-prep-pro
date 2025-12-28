import Foundation

public struct QuizResult: Identifiable, Codable {
    public let id: UUID
    public let date: Date
    public let score: Int
    public let totalQuestions: Int
    public let percentage: Double
    public let timeSpent: Int  // Time spent on the quiz in seconds
    public let timeLimit: Int  // Time limit for the quiz in seconds

    public init(score: Int, totalQuestions: Int, timeSpent: Int, timeLimit: Int) {
        self.id = UUID()
        self.date = Date()
        self.score = score
        self.totalQuestions = totalQuestions
        self.percentage = Double(score) / Double(totalQuestions) * 100
        self.timeSpent = timeSpent
        self.timeLimit = timeLimit
    }
}
