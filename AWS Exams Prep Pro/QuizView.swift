import SwiftUI

struct QuizView: View {
    @State private var currentQuestionIndex: Int = 0
    @State private var selectedOptions: Set<String> = []
    @State private var showExplanation: Bool = false
    @State private var isAnswerCorrect: Bool = false
    @State private var showNextQuestionButton: Bool = false
    @State private var correctAnswersCount: Int = 0
    @State private var quizCompleted: Bool = false
    @State private var showConfetti: Bool = false
    @State private var showReviewPrompt: Bool = false
    @State private var userLikedApp: Bool?
    @State private var showFeedbackModal: Bool = false
    @State private var feedbackText: String = ""
    @State private var showFeedbackConfirmation: Bool = false
    @State private var showAdAlert: Bool = false
    
    // Timer properties
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var timerStarted: Bool = false
    
    let questions: [QuizQuestion]
    let timeLimit: Int
    let totalPoolSize: Int
    let isQuickQuiz: Bool // Add this to track quiz type
    
    init(questions: [QuizQuestion], timeLimit: Int, totalPoolSize: Int) {
        self.questions = questions
        self.timeLimit = timeLimit
        self.totalPoolSize = totalPoolSize
        self._timeRemaining = State(initialValue: timeLimit)
        self.isQuickQuiz = timeLimit == 12 * 60 // 12 minutes indicates quick quiz
    }
    
    private func restartQuiz() {
        if QuizLimitManager.shared.canStartQuiz() {
            // Reset all states to restart the quiz
            currentQuestionIndex = 0
            correctAnswersCount = 0
            quizCompleted = false
            selectedOptions = []
            showExplanation = false
            showNextQuestionButton = false
            showConfetti = false
            showReviewPrompt = false
            userLikedApp = nil
            timeRemaining = timeLimit
            timerStarted = false
            stopTimer()
            
            // Use an attempt
            QuizLimitManager.shared.useAttempt()
        } else {
            // Show ad alert if no attempts left
            showAdAlert = true
        }
    }

    var body: some View {
        ZStack {
            // ... existing view code ...
            
            if quizCompleted {
                let percentage = Double(correctAnswersCount) / Double(questions.count) * 100
                let passed = percentage >= 70
                
                if passed {
                    Text("You Passed!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.green)
                        
                    CelebrationTrophy()
                        .frame(width: 200, height: 200)
                        .padding()
                } else {
                    Text("You Did Not Pass")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.red)
                }
                
                Text("Your Score: \(correctAnswersCount) / \(questions.count) (\(String(format: "%.1f", percentage))%)")
                    .font(.headline)
                    .padding()
                
                Button(action: restartQuiz) {
                    Text("Restart Quiz")
                        .padding()
                        .background(QuizLimitManager.shared.canStartQuiz() ? Color.blue : Color(.systemGray5))
                        .foregroundColor(QuizLimitManager.shared.canStartQuiz() ? .white : .gray)
                        .cornerRadius(10)
                        .padding(.top, 20)
                }
                .alert("Watch Ad to Unlock", isPresented: $showAdAlert) {
                    Button("Watch Ad") {
                        AdManager.shared.showRewardedInterstitialAd { success in
                            if success {
                                QuizLimitManager.shared.addAttempt()
                                // Automatically restart the quiz after successful ad
                                restartQuiz()
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Watch a short ad to unlock an additional quiz attempt.")
                }
            }
            
            // ... rest of the view code ...
        }
    }
    
    // ... rest of the existing code ...
} 