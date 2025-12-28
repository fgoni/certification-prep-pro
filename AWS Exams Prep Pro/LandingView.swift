import SwiftUI

struct LandingScreenView: View {
    @State private var selectedQuestionSet: QuestionSet = .cloudPractitioner
    @State private var isFullQuizActive = false
    @State private var isQuickQuizActive = false
    @State private var showExamSelector = false
    @State private var showAdAlert = false
    @State private var adRewardType: QuizType?
    
    @StateObject private var quizData = QuizQuestions()
    @StateObject private var quizLimitManager = QuizLimitManager.shared
    @StateObject private var adManager = AdManager.shared
    
    let blue = Color(hue: 0.57, saturation: 0.80, brightness: 0.39)
    
    enum QuizType {
        case quick
        case full
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                QuizLimitBar()
                    .padding(.top, 10)
                
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
                }

                // Exam Selection Button
                Button(action: {
                    showExamSelector = true
                }) {
                    HStack {
                        Text(selectedQuestionSet.title)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Show the number of questions loaded
                Text("Loaded \(quizData.allQuizQuestions.count) questions")
                    .font(.caption)
                    .foregroundColor(.gray)

                // Full Quiz Button
                Button {
                    if QuizLimitManager.shared.canStartQuiz() {
                        QuizLimitManager.shared.useAttempt()
                        isFullQuizActive = true
                    } else {
                        adRewardType = .full
                        showAdAlert = true
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Full Quiz")
                                .font(.headline)
                            Text("65 Questions • 40 Minutes")
                                .font(.caption)
                            if !QuizLimitManager.shared.canStartQuiz() {
                                Text("Watch ad to unlock")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .foregroundColor(QuizLimitManager.shared.canStartQuiz() ? .primary : .secondary)
                    .cornerRadius(12)
                }
                .navigationDestination(isPresented: $isFullQuizActive) {
                    QuizView(
                        questions: Array(quizData.allQuizQuestions.shuffled().prefix(65)), 
                        timeLimit: 40 * 60,
                        totalPoolSize: quizData.getTotalQuizQuestions()
                    )
                }

                // Quick Quiz Button
                Button {
                    if QuizLimitManager.shared.canStartQuiz() {
                        QuizLimitManager.shared.useAttempt()
                        isQuickQuizActive = true
                    } else {
                        adRewardType = .quick
                        showAdAlert = true
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick Quiz")
                                .font(.headline)
                            Text("20 Questions • 12 Minutes")
                                .font(.caption)
                            if !QuizLimitManager.shared.canStartQuiz() {
                                Text("Watch ad to unlock")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .foregroundColor(QuizLimitManager.shared.canStartQuiz() ? .primary : .secondary)
                    .cornerRadius(12)
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
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Historical Results")
                                .font(.headline)
                            Text("View your past quiz performances")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
            .alert("Watch an Ad to Unlock More Quizzes", isPresented: $showAdAlert) {
                Button("Watch Ad") {
                    AdManager.shared.showRewardedInterstitialAd { success in
                        if success {
                            QuizLimitManager.shared.addAttempt()
                            QuizLimitManager.shared.useAttempt()
                            showAdAlert = false
                            
                            // Automatically start the quiz after successful ad
                            if let type = adRewardType {
                                switch type {
                                case .quick:
                                    isQuickQuizActive = true
                                case .full:
                                    isFullQuizActive = true
                                }
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    showAdAlert = false
                }
            } message: {
                Text("Watch a short ad to get an additional quiz attempt.")
            }
            .sheet(isPresented: $showExamSelector) {
                ExamSelectorView(selectedExam: $selectedQuestionSet, isPresented: $showExamSelector)
            }
            .onChange(of: selectedQuestionSet) { newValue in
                switch newValue {
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
            .onAppear {
                // Ensure the correct question set is loaded initially
                switch selectedQuestionSet {
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
    }
}

// MARK: - Quiz Limit Bar
struct QuizLimitBar: View {
    @StateObject private var quizLimitManager = QuizLimitManager.shared

    var body: some View {
        HStack(spacing: 12) {
            // Credits Card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0))

                    Text("CREDITS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0))
                }

                Text("\(quizLimitManager.remainingAttempts) of 3 Remaining")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 1.0, green: 0.95, blue: 0.9))
            .cornerRadius(16)

            // Next Refill Card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))

                    Text("NEXT REFILL")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                }

                Text(quizLimitManager.timeUntilReset())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.35, blue: 0.95))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Exam Selector View
struct ExamSelectorView: View {
    @Binding var selectedExam: QuestionSet
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("AWS Certifications")) {
                    ForEach(QuestionSet.allCases, id: \.self) { exam in
                        Button(action: {
                            selectedExam = exam
                            isPresented = false
                        }) {
                            HStack {
                                Text(exam.title)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedExam == exam {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Exam")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

enum QuestionSet: CaseIterable {
    case cloudPractitioner
    case softwareArchitectAssociate
    case developerAssociate
    case sysOpsAssociate
    
    var title: String {
        switch self {
        case .cloudPractitioner:
            return "AWS Cloud Practitioner"
        case .softwareArchitectAssociate:
            return "AWS Solutions Architect Associate"
        case .developerAssociate:
            return "AWS Developer Associate"
        case .sysOpsAssociate:
            return "AWS SysOps Administrator Associate"
        }
    }
}

// MARK: - PreviewProvider
struct LandingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreenView()
            .previewDevice("iPhone 14")
            .previewDisplayName("iPhone 14")
    }
}
