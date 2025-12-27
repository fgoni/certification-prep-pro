import Foundation
import Combine

/// ViewModel for Landing screen
/// Handles business logic and dependency injection
class LandingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedQuestionSet: QuestionSet = .cloudPractitioner
    @Published var isFullQuizActive = false
    @Published var isQuickQuizActive = false
    @Published var showExamSelector = false
    @Published var showAdAlert = false
    @Published var adRewardType: QuizType?

    @Published var quizData = QuizQuestions()

    // MARK: - Dependencies (injected)
    private let quizLimitProvider: QuizLimitProviderProtocol
    private let adProvider: AdProviderProtocol

    // MARK: - Initialization
    init(
        quizLimitProvider: QuizLimitProviderProtocol = QuizLimitManager.shared,
        adProvider: AdProviderProtocol = AdManager.shared
    ) {
        self.quizLimitProvider = quizLimitProvider
        self.adProvider = adProvider
        loadInitialQuestionSet()
    }

    // MARK: - Public Methods
    func startFullQuiz() {
        if quizLimitProvider.canStartQuiz() {
            quizLimitProvider.useAttempt()
            isFullQuizActive = true
        } else {
            adRewardType = .full
            showAdAlert = true
        }
    }

    func startQuickQuiz() {
        if quizLimitProvider.canStartQuiz() {
            quizLimitProvider.useAttempt()
            isQuickQuizActive = true
        } else {
            adRewardType = .quick
            showAdAlert = true
        }
    }

    func watchAdToUnlock() {
        adProvider.showAd { [weak self] success in
            guard let self = self else { return }

            if success {
                self.quizLimitProvider.addAttempt()
                self.quizLimitProvider.useAttempt()
                self.showAdAlert = false

                // Automatically start the quiz after successful ad
                if let type = self.adRewardType {
                    switch type {
                    case .quick:
                        self.isQuickQuizActive = true
                    case .full:
                        self.isFullQuizActive = true
                    }
                }
            }
        }
    }

    func changeQuestionSet(to set: QuestionSet) {
        selectedQuestionSet = set
        loadQuestionSet(for: set)
    }

    // MARK: - Private Methods
    private func loadInitialQuestionSet() {
        loadQuestionSet(for: selectedQuestionSet)
    }

    private func loadQuestionSet(for set: QuestionSet) {
        switch set {
        case .cloudPractitioner:
            quizData.switchToCloudPractitioner()
        case .softwareArchitectAssociate:
            quizData.switchToSoftwareArchitectAssociate()
        case .developerAssociate:
            quizData.switchToDeveloperAssociate()
        case .sysOpsAssociate:
            quizData.switchToSysOpsAssociate()
        }
    }
}

// MARK: - Supporting Types
extension LandingViewModel {
    enum QuizType {
        case quick
        case full
    }
}
