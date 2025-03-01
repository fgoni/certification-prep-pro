//
//  QuizViewPreviewProvider.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 11/08/2024.
//

import Foundation
import SwiftUI

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleQuestions = [
            QuizQuestion(
                id: UUID(),
                questionText: "What is AWS?",
                options: ["A cloud computing service", "A programming language", "A database", "An operating system"],
                correctAnswer: "A cloud computing service",
                explanation: "AWS stands for Amazon Web Services.",
                category: "General"
            ),
            QuizQuestion(
                id: UUID(),
                questionText: "Which of the following is a compute service?",
                options: ["S3", "Lambda", "RDS", "CloudFront"],
                correctAnswer: "Lambda",
                explanation: "AWS Lambda is a compute service.",
                category: "Compute"
            )
        ]
        
        QuizView(questions: sampleQuestions)
    }
}
