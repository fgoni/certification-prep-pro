import SwiftUI

/// Landing screen - main entry point for the app
/// Uses LandingViewModel for business logic and dependency injection
struct LandingScreenView: View {
    @StateObject private var viewModel: LandingViewModel

    init(
        quizLimitProvider: QuizLimitProviderProtocol = QuizLimitManager.shared,
        adProvider: AdProviderProtocol = AdManager.shared
    ) {
        _viewModel = StateObject(wrappedValue: LandingViewModel(
            quizLimitProvider: quizLimitProvider,
            adProvider: adProvider
        ))
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
                    viewModel.showExamSelector = true
                }) {
                    HStack {
                        Text(viewModel.selectedQuestionSet.title)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Show the number of questions loaded
                Text("Loaded \(viewModel.quizData.allQuizQuestions.count) questions")
                    .font(.caption)
                    .foregroundColor(.gray)

                // Full Quiz Button
                ActionCardView(
                    title: "Full Quiz",
                    subtitle: "65 Questions • 40 Minutes",
                    icon: "arrow.right.circle.fill",
                    iconColor: .blue,
                    isEnabled: QuizLimitManager.shared.canStartQuiz(),
                    showLock: !QuizLimitManager.shared.canStartQuiz(),
                    action: { viewModel.startFullQuiz() }
                )
                .navigationDestination(isPresented: $viewModel.isFullQuizActive) {
                    QuizView(
                        questions: Array(viewModel.quizData.allQuizQuestions.shuffled().prefix(65)),
                        timeLimit: 40 * 60,
                        totalPoolSize: viewModel.quizData.getTotalQuizQuestions()
                    )
                }

                // Quick Quiz Button
                ActionCardView(
                    title: "Quick Quiz",
                    subtitle: "20 Questions • 12 Minutes",
                    icon: "arrow.right.circle.fill",
                    iconColor: .blue,
                    isEnabled: QuizLimitManager.shared.canStartQuiz(),
                    showLock: !QuizLimitManager.shared.canStartQuiz(),
                    action: { viewModel.startQuickQuiz() }
                )
                .navigationDestination(isPresented: $viewModel.isQuickQuizActive) {
                    QuizView(
                        questions: Array(viewModel.quizData.allQuizQuestions.shuffled().prefix(20)),
                        timeLimit: 12 * 60,
                        totalPoolSize: viewModel.quizData.getTotalQuizQuestions()
                    )
                }

                // NavigationLink for Historical Results
                NavigationLink(destination: HistoricalResultsView()) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Historical Results")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)

                            Text("View your past quiz performances")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Blue circular badge with chart icon
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 36, height: 36)

                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding()
            .alert("Watch an Ad to Unlock More Quizzes", isPresented: $viewModel.showAdAlert) {
                Button("Watch Ad") {
                    viewModel.watchAdToUnlock()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.showAdAlert = false
                }
            } message: {
                Text("Watch a short ad to get an additional quiz attempt.")
            }
            .sheet(isPresented: $viewModel.showExamSelector) {
                ExamSelectorView(selectedExam: $viewModel.selectedQuestionSet, isPresented: $viewModel.showExamSelector)
            }
            .onChange(of: viewModel.selectedQuestionSet) { newValue in
                viewModel.changeQuestionSet(to: newValue)
            }
            .onAppear {
                // Question set is loaded during ViewModel initialization
                // No additional loading needed here
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LandingScreenView()
}
