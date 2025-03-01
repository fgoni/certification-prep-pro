//
//  QuizStruct.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 11/08/2024.
//

import Foundation

struct QuizQuestion: Identifiable {
    let id: UUID
    let questionText: String
    let options: [String]
    let correctAnswer: String
    let explanation: String?
    let category: String
}
