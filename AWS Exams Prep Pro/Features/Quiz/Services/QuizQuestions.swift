import Foundation
import Combine

/// Manages quiz questions for different exam sets
class QuizQuestions: ObservableObject {
    @Published var allQuizQuestions: [QuizQuestion] = []

    init(setName: String = "cloud-practitioner-questions") {
        switch setName {
        case "cloud-practitioner-questions":
            switchToCloudPractitioner()
        case "software-architect-associate-questions":
            switchToSoftwareArchitectAssociate()
        case "developer-associate-questions":
            switchToDeveloperAssociate()
        case "sysops-associate-questions":
            switchToSysOpsAssociate()
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
    private let developerAssociateQuestions = "developer-associate-questions"
    private let sysOpsAssociateQuestions = "sysops-associate-questions"

    func loadQuestionSet(_ setName: String) {
        allQuizQuestions = QuestionLoader.loadQuestions(from: setName)
    }

    func switchToCloudPractitioner() {
        loadQuestionSet(cloudPractitionerQuestions)
    }

    func switchToSoftwareArchitectAssociate() {
        loadQuestionSet(softwareArchitectAssociateQuestions)
    }

    func switchToDeveloperAssociate() {
        loadQuestionSet(developerAssociateQuestions)
    }

    func switchToSysOpsAssociate() {
        loadQuestionSet(sysOpsAssociateQuestions)
    }
}
