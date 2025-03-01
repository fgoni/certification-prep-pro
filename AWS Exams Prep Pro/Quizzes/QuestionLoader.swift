//
//  QuestionLoader.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 24/02/2025.
//
import Foundation;

// QuestionLoader.swift
class QuestionLoader {
    static func loadQuestions(from filename: String) -> [QuizQuestion] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Could not find \(filename).json in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([QuizQuestion].self, from: data)
            return questions
        } catch {
            print("Error loading questions: \(error)")
            return []
        }
    }
}
