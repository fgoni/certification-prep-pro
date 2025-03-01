import Foundation

class QuizQuestions: ObservableObject {
    @Published var allQuizQuestions: [QuizQuestion] = []
    
    init(setName: String = "cloud-practitioner-questions") {
        switch setName {
        case "cloud-practitioner-questions":
            switchToCloudPractitioner()
            break
        case "software-architect-associate-questions":
            switchToSoftwareArchitectAssociate()
            break
        default:
            switchToCloudPractitioner()
        }
    }

    func getRandomQuizQuestions(count: Int) -> [QuizQuestion] {
        return Array(allQuizQuestions.shuffled().prefix(count))
    }

    func getTotalQuizQuestions() -> Int {
        return allQuizQuestions.count
    }

    private let cloudPractitionerQuestions = "cloud-practitioner-questions"
    private let softwareArchitectAssociateQuestions = "software-architect-associate-questions"

    func loadQuestionSet(_ setName: String) {
        allQuizQuestions = QuestionLoader.loadQuestions(from: setName)
    }

    func switchToCloudPractitioner() {
        loadQuestionSet(cloudPractitionerQuestions)
    }

    func switchToSoftwareArchitectAssociate() {
        loadQuestionSet(softwareArchitectAssociateQuestions)
    }
}
