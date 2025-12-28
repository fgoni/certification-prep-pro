import SwiftUI

/// Theme toggle button for switching between light/dark/system modes
struct ThemeToggleButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme

    private var currentScheme: ColorScheme {
        themeManager.colorScheme ?? systemColorScheme
    }

    private var iconName: String {
        switch currentScheme {
        case .light:
            return "moon.fill"
        case .dark:
            return "sun.max.fill"
        @unknown default:
            return "circle.lefthalf.filled"
        }
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.toggleTheme()
            }
        }) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: 44, height: 44)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(Circle())
                .shadow(
                    color: Color.black.opacity(currentScheme == .dark ? 0.3 : 0.1),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .transition(.scale.combined(with: .opacity))
    }
}

/// Landing screen - main entry point for the app
/// Uses LandingViewModel for business logic and dependency injection
struct LandingScreenView: View {
    @StateObject private var viewModel: LandingViewModel
    @EnvironmentObject var themeManager: ThemeManager

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
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(" for AWS")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .opacity(0.6)
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
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(AppTheme.Colors.examSelectorBackground)
                    .cornerRadius(10)
                }

                // Show the number of questions loaded
                Text("Loaded \(viewModel.quizData.allQuizQuestions.count) questions")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)

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
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("View your past quiz performances")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.accentBlue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.actionCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.actionCardBorder, lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding()
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
            .overlay(
                ThemeToggleButton()
                    .padding(.trailing, 16)
                    .padding(.bottom, 16),
                alignment: .bottomTrailing
            )
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
#Preview("Light Mode") {
    LandingScreenView()
        .environmentObject(ThemeManager())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    LandingScreenView()
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
}
