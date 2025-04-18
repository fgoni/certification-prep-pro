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
                    if quizLimitManager.canStartQuiz() {
                        isFullQuizActive = true
                        quizLimitManager.useAttempt()
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
                            if !quizLimitManager.canStartQuiz() {
                                Text("Watch ad to unlock")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(quizLimitManager.canStartQuiz() ? Color.blue : Color(.systemGray5))
                    .foregroundColor(quizLimitManager.canStartQuiz() ? .white : .gray)
                    .cornerRadius(8)
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
                    if quizLimitManager.canStartQuiz() {
                        isQuickQuizActive = true
                        quizLimitManager.useAttempt()
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
                            if !quizLimitManager.canStartQuiz() {
                                Text("Watch ad to unlock")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(quizLimitManager.canStartQuiz() ? Color.blue : Color(.systemGray5))
                    .foregroundColor(quizLimitManager.canStartQuiz() ? .white : .gray)
                    .cornerRadius(8)
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
                Text("Built by CoffeeDevs LLC 2025")
            }
            .padding()
            .alert("Watch Ad to Unlock", isPresented: $showAdAlert) {
                Button("Watch Ad") {
                    adManager.showRewardedInterstitialAd { success in
                        if success {
                            quizLimitManager.addAttempt()
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
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Watch a short ad to unlock an additional quiz attempt.")
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
}

// MARK: - Quiz Limit Bar
struct QuizLimitBar: View {
    @StateObject private var quizLimitManager = QuizLimitManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                Text("\(quizLimitManager.remainingAttempts)/3")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text(quizLimitManager.timeUntilReset())
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
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
    
    var title: String {
        switch self {
        case .cloudPractitioner:
            return "AWS Cloud Practitioner"
        case .softwareArchitectAssociate:
            return "AWS Solutions Architect Associate"
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
