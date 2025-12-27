import Foundation

/// Protocol defining quiz result persistence capabilities
public protocol QuizResultStorageProtocol {
    /// Saves a quiz result to persistent storage
    /// - Parameter result: The quiz result to save
    func saveResult(_ result: QuizResult)

    /// Fetches all stored quiz results
    /// - Returns: Array of QuizResult objects
    func fetchResults() -> [QuizResult]
}
