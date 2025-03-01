import SwiftUI

struct LandingScreenView: View {
    @State private var selectedQuestionSet: QuestionSet = .cloudPractitioner // Default selection
    @State private var isFullQuizActive = false
    @State private var isQuickQuizActive = false

    @StateObject private var quizData = QuizQuestions() // Change to @StateObject to properly manage the lifecycle

    let blue = Color(hue: 0.57, saturation: 0.80, brightness: 0.39)

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Text("Certification Prep Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(" for AWS")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.padding(.bottom, 20)

                // Question Set Selection
                Picker("Select Question Set", selection: $selectedQuestionSet) {
                    Text("Cloud Practitioner").tag(QuestionSet.cloudPractitioner)
                    Text("Solution Architect Associate").tag(QuestionSet.softwareArchitectAssociate)
                }
                .pickerStyle(.segmented)
                
                // Show the number of questions loaded
                Text("Loaded \(quizData.allQuizQuestions.count) questions")
                    .font(.caption)
                    .foregroundColor(.gray)

                // NavigationLink for Full Quiz - uses binding to correctly initialize when tapped
                Button {
                    isFullQuizActive = true
                } label: {
                    Text("Start Full Quiz (65 Questions, 40 Minutes)")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .navigationDestination(isPresented: $isFullQuizActive) {
                    QuizView(
                        questions: Array(quizData.allQuizQuestions.shuffled().prefix(65)), 
                        timeLimit: 40 * 60,
                        totalPoolSize: quizData.getTotalQuizQuestions()
                    )
                }

                // NavigationLink for Quick Quiz - uses binding to correctly initialize when tapped
                Button {
                    isQuickQuizActive = true
                } label: {
                    Text("Start Quick Quiz (20 Questions, 12 Minutes)")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .navigationDestination(isPresented: $isQuickQuizActive) {
                    QuizView(
                        questions: Array(quizData.allQuizQuestions.shuffled().prefix(20)), 
                        timeLimit: 12 * 60,
                        totalPoolSize: quizData.getTotalQuizQuestions()
                    )
                }

                // NavigationLink for Historical Results
                NavigationLink(destination: HistoricalResultsView()) { 
                    Text("View Historical Results")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .onChange(of: selectedQuestionSet) { newValue in
                switch newValue {
                case .cloudPractitioner:
                    quizData.switchToCloudPractitioner()
                case .softwareArchitectAssociate:
                    quizData.switchToSoftwareArchitectAssociate()
                }
            }
            .onAppear {
                // Ensure the correct question set is loaded initially
                switch selectedQuestionSet {
                case .cloudPractitioner:
                    quizData.switchToCloudPractitioner()
                case .softwareArchitectAssociate:
                    quizData.switchToSoftwareArchitectAssociate()
                }
            }
        }
    }

    // Helper function to get questions for the selected set
    func getQuestionsForSelectedSet(questionSet: QuestionSet, count: Int) -> [QuizQuestion] {
        return Array(quizData.allQuizQuestions.shuffled().prefix(count))
    }
}

enum QuestionSet {
    case cloudPractitioner
    case softwareArchitectAssociate
}

// MARK: - PreviewProvider
struct LandingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreenView()
            .previewDevice("iPhone 14")
            .previewDisplayName("iPhone 14")
    }
}
