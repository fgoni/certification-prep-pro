import SwiftUI

// MARK: - QuizQuestion Model
struct QuizQuestion: Decodable {
    let id: String
    let questionText: String
    let options: [String]
    let correctAnswers: [String]
    let explanation: String?
    let category: String
}

// MARK: - QuizView
struct QuizView: View {
    @ObservedObject var quizStore = QuizQuestions()
    @State private var currentQuestionIndex: Int = 0
    @State private var selectedOptions: Set<String> = [] // Updated to allow selecting multiple options
    @State private var showExplanation: Bool = false
    @State private var isAnswerCorrect: Bool = false // Econ
    @State private var showNextQuestionButton: Bool = false
    @State private var correctAnswersCount: Int = 0 // Track the number of correct answers
    @State private var quizCompleted: Bool = false // Track if the quiz is completed

    @State private var showConfetti: Bool = false // State to trigger confetti animation
    
    // Timer properties
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var timerStarted: Bool = false // Track if the timer has started

    
    let questions: [QuizQuestion]
    let timeLimit: Int
    
    init(questions: [QuizQuestion], timeLimit: Int) {
        self.questions = questions
        self.timeLimit = timeLimit
        self._timeRemaining = State(initialValue: timeLimit) // Initialize the timer with the provided limit
    }
    
    var body: some View {
        ZStack {
            // Background image
           // Image("Image")
             //   .resizable()
               // .scaledToFill()
               // .edgesIgnoringSafeArea(.all)
               // .frame(maxWidth: .infinity, maxHeight: .infinity)

            
            VStack {
                // Title at the top
                Text(questions.count > 20 ? "Full Quiz" :"Quick Quiz")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.all, 10)
                    .fixedSize(horizontal: false, vertical: true)

                
                // Timer display
                Button(action: toggleTimer) {
                    HStack {
                        Text("Time Remaining: \(formatTime(timeRemaining))")
                            .font(.headline)
                        Image(systemName: timerStarted ? "pause.circle" : "play.circle")
                            .font(.headline)
                            .padding(.leading, 5)
                    }
                }
                
                
                
                if quizCompleted {
                    let percentage = Double(correctAnswersCount) / Double(questions.count) * 100
                    let passed = percentage >= 70
                    
                    if passed {
                        Text("You Passed!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(.green)
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
                    
                    if passed && showConfetti {
                        ConfettiView() // Use the new ConfettiView here
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .padding(.top, 20)
                    }
                    
                    Button(action: restartQuiz) {
                        Text("Restart Quiz")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 20)
                    }
                } else {
                    if questions.isEmpty {
                        Text("No questions available")
                            .font(.headline)
                            .padding()
                    } else {
                        ScrollView {
                            Text(questions[currentQuestionIndex].questionText)
                                .font(.headline)
                                .padding(10)
                                .fixedSize(horizontal: false, vertical: true)
                        
                            ForEach(questions[currentQuestionIndex].options, id: \.self) { option in
                                Button(action: {
                                    toggleSelection(of: option)
                                }) {
                                    Text(option)
                                        .multilineTextAlignment(.center)
                                        .padding(8)
                                        .frame(maxWidth: .infinity)
                                        .background(colorForOption(option)) // Highlight the option based on correctness
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.vertical, 2)
                                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                    
                                }
                            }
                        }
                        
                        if showNextQuestionButton {
                            if showExplanation, let explanation = questions[currentQuestionIndex].explanation {
                                Text(explanation)
                                    .font(.subheadline)
                                    .padding()
                            }
                            
                            Button(action: goToNextQuestion) {
                                Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Finish Quiz")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.top, 20)
                            }
                        } else {
                            Button(action: {
                                if !timerStarted {
                                    startTimer()
                                    timerStarted = true
                                }
                                checkAnswer()
                            }) {
                                Text("Submit")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(submitButtonDisabled() ? Color.gray : Color.blue) // Disable color when no options are selected
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.top, 20)
                            }
                            .disabled(submitButtonDisabled()) // Disable button if no options are selected
                        }
                        
                        // Progress Indicator
                        VStack {
                            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                                .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
                                .padding(.vertical, 10)
                            
                            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                                .font(.caption)
                                .padding(.bottom, 10)
                            
                            Text("From a pool of \(quizStore.getTotalQuizQuestions()) questions.")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    private func submitButtonDisabled() -> Bool {
        let correctAnswers = questions[currentQuestionIndex].correctAnswers
        let tmpAnswerCorrect = Set(correctAnswers) == selectedOptions
        if tmpAnswerCorrect {
            print("true");
        }
        
        let disabled =  selectedOptions.count < questions[currentQuestionIndex].correctAnswers.count
        
        return disabled
    }

    private func toggleSelection(of option: String) {
        let answersCount = questions[currentQuestionIndex].correctAnswers.count
        
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            if selectedOptions.count < answersCount {
                selectedOptions.insert(option)
            } else {
                selectedOptions.removeFirst()
                selectedOptions.insert(option)
            }
        }
    }

    private func checkAnswer() {
        let correctAnswers = questions[currentQuestionIndex].correctAnswers
        isAnswerCorrect = Set(correctAnswers) == selectedOptions
        if isAnswerCorrect {
            correctAnswersCount += 1
        }
        showExplanation = true
        showNextQuestionButton = true
    }

    private func goToNextQuestion() {
        showNextQuestionButton = false
        showExplanation = false
        selectedOptions = []
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            // Mark the quiz as completed and display the score
            quizCompleted = true
            stopTimer()
            
            
            // Calculate the time spent
            let timeSpent = timeLimit - timeRemaining
            
            // Save the result when the quiz is completed
            let result = QuizResult(
                score: correctAnswersCount,
                totalQuestions: questions.count,
                timeSpent: timeSpent,
                timeLimit: timeLimit
            )
            QuizResultsManager.shared.saveResult(result)
            
            
            // Trigger confetti if the user passed
            let percentage = Double(correctAnswersCount) / Double(questions.count) * 100
            showConfetti = percentage >= 70
        }
    }

    private func restartQuiz() {
        // Reset all states to restart the quiz
        currentQuestionIndex = 0
        correctAnswersCount = 0
        quizCompleted = false
        selectedOptions = []
        showExplanation = false
        showNextQuestionButton = false
        showConfetti = false
        timeRemaining = 2400 // Reset the timer to 40 minutes
        timerStarted = false // Mark timer as not started
        stopTimer() // Ensure the previous timer is stopped
    }

    private func colorForOption(_ option: String) -> Color {
        guard showNextQuestionButton else {
            return selectedOptions.contains(option) ? Color.blue : Color.gray
        }

        let correctAnswers = questions[currentQuestionIndex].correctAnswers
        if correctAnswers.contains(option) {
            return .green // Correct answer
        } else if selectedOptions.contains(option) {
            return .red // Incorrect answer
        } else {
            return .gray // Unselected options remain gray
        }
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.quizCompleted = true
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func toggleTimer() {
       timerStarted = !timerStarted
        if (timerStarted){
            startTimer()
        }
        else {
            stopTimer()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - PreviewProvider
class QuizView_Previews: PreviewProvider {
    static var previews: some View {
        let quizStore = QuizQuestions.init(setName: "software-architect-associate-questions")
        // Use the getRandomQuizQuestions method to get a random selection of questions
        let sampleQuestions = quizStore.getRandomQuizQuestions(count: 4)
        let sampleTimeLimit = 160;
        
        QuizView(questions: sampleQuestions, timeLimit: sampleTimeLimit)
            .previewDevice("iPhone 14")
            .previewDisplayName("iPhone 14")
    }
}
