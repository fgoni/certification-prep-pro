import SwiftUI

struct LandingScreenView: View {
    @State private var selectedQuestionSet: QuestionSet = .cloudPractitioner // Default selection

    @ObservedObject var quizData = QuizQuestions() // Assuming QuizQuestions is your ObservableObject

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
                    Text("Software Architect Associate").tag(QuestionSet.softwareArchitectAssociate)
                }
                .pickerStyle(.segmented)

                // NavigationLink for Full Quiz
                NavigationLink(destination: QuizView(questions: getQuestionsForSelectedSet(questionSet: selectedQuestionSet, count: 65), timeLimit: 40 * 60)) {
                    Text("Start Full Quiz (65 Questions, 40 Minutes)")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // NavigationLink for Quick Quiz
                NavigationLink(destination: QuizView(questions: getQuestionsForSelectedSet(questionSet: selectedQuestionSet, count: 20), timeLimit: 12 * 60)) {
                    Text("Start Quick Quiz (20 Questions, 12 Minutes)")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // NavigationLink for Historical Results
                NavigationLink(destination: HistoricalResultsView()) { // Replace with your HistoricalResultsView
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
                    quizData.init(setName: "cloud-practitioner-questions")
                case .softwareArchitectAssociate:
                    quizData.init(setName: "software-architect-associate-questions")
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
        LandingScreenView(quizData: QuizQuestions()) // Provide a QuizQuestions instance
            .previewDevice("iPhone 14")
            .previewDisplayName("iPhone 14")
    }
}
