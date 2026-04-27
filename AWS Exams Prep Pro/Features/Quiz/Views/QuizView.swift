import SwiftUI
import StoreKit
import os.log

private let logger = Logger(subsystem: "com.coffeedevs.capuccino", category: "QuizView")

// MARK: - QuizView (V1 Refined)
struct QuizView: View {
    @State private var currentQuestionIndex: Int = 0
    @State private var selectedOptions: Set<String> = []
    @State private var showExplanation: Bool = false
    @State private var isAnswerCorrect: Bool = false
    @State private var showNextQuestionButton: Bool = false
    @State private var correctAnswersCount: Int = 0
    @State private var quizCompleted: Bool = false

    @State private var showReviewPrompt: Bool = false
    @State private var userLikedApp: Bool? = nil
    @State private var showFeedbackModal: Bool = false
    @State private var feedbackText: String = ""
    @State private var showFeedbackConfirmation: Bool = false

    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var timerStarted: Bool = false

    @State private var marked: Set<Int> = []
    @State private var transitioning: Bool = false
    @State private var domainBreakdown: [(name: String, pct: Int)] = []

    @Environment(\.dismiss) private var dismiss

    let questions: [QuizQuestion]
    let timeLimit: Int
    let totalPoolSize: Int

    init(questions: [QuizQuestion], timeLimit: Int, totalPoolSize: Int) {
        self.questions = questions
        self.timeLimit = timeLimit
        self.totalPoolSize = totalPoolSize
        self._timeRemaining = State(initialValue: timeLimit)
    }

    var body: some View {
        ZStack {
            AppTheme.V1.Colors.bg.ignoresSafeArea()

            if quizCompleted {
                ResultView(
                    score: correctAnswersCount,
                    total: questions.count,
                    timeSpent: timeLimit - timeRemaining,
                    breakdown: domainBreakdown,
                    onHome: { dismiss() },
                    onRestart: restartQuiz
                )
            } else if questions.isEmpty {
                Text("No questions available")
                    .font(AppTheme.V1.Typography.bodyEmphasis)
                    .foregroundStyle(AppTheme.V1.Colors.muted)
            } else {
                quizBody
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear { stopTimer() }
        .alert("Did you enjoy using the app?", isPresented: $showReviewPrompt) {
            Button("Yes") {
                userLikedApp = true
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            Button("No") {
                userLikedApp = false
                showFeedbackModal = true
            }
        }
        .sheet(isPresented: $showFeedbackModal) {
            feedbackSheet
        }
        .alert("Thank You!", isPresented: $showFeedbackConfirmation) {
            Button("OK") {
                showFeedbackModal = false
                feedbackText = ""
            }
        } message: {
            Text("Thank you for your feedback. We'll take it into account to improve the app.")
        }
    }

    // MARK: - Quiz body
    private var quizBody: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView(showsIndicators: false) {
                questionContent
                    .padding(.horizontal, AppTheme.V1.Metrics.pad)
                    .padding(.bottom, 12)
            }
            actionBar
        }
    }

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Path { path in
                            path.move(to: CGPoint(x: 5, y: 1))
                            path.addLine(to: CGPoint(x: 1, y: 5.5))
                            path.addLine(to: CGPoint(x: 5, y: 10))
                        }
                        .stroke(AppTheme.V1.Colors.muted,
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                        .frame(width: 6, height: 11)
                        Text("Exit")
                            .font(AppTheme.V1.Typography.label)
                            .foregroundStyle(AppTheme.V1.Colors.muted)
                    }
                    .padding(4)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(currentQuestionIndex + 1) / \(questions.count)")
                    .font(AppTheme.V1.Typography.smallEmphasis)
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.V1.Colors.muted)

                Spacer()

                Button(action: toggleMark) {
                    let isMarked = marked.contains(currentQuestionIndex)
                    Image(systemName: isMarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isMarked ? AppTheme.V1.Colors.warn : AppTheme.V1.Colors.muted)
                        .padding(4)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                GeometryReader { geo in
                    let progress = Double(currentQuestionIndex) / Double(max(1, questions.count))
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppTheme.V1.Colors.hair)
                        Capsule()
                            .fill(AppTheme.V1.Colors.accent)
                            .frame(width: max(0, CGFloat(progress) * geo.size.width))
                            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.4), value: progress)
                    }
                }
                .frame(height: 4)

                Button(action: toggleTimer) {
                    HStack(spacing: 4) {
                        Image(systemName: timerStarted ? "pause.fill" : "play.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 12, weight: .bold))
                            .monospacedDigit()
                    }
                    .foregroundStyle(timeRemaining < 60 ? AppTheme.V1.Colors.danger : AppTheme.V1.Colors.ink)
                    .opacity(timeRemaining < 60 ? pulseOpacity : 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.V1.Metrics.pad - 2)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    @State private var pulseOpacity: Double = 1
    private var questionContent: some View {
        let q = questions[currentQuestionIndex]
        let displayDomain = q.category.isEmpty ? "GENERAL" : q.category
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                V1Pill(text: displayDomain,
                       color: AppTheme.V1.Colors.accent,
                       background: AppTheme.V1.Colors.accentSoft)
                V1Pill(text: q.correctAnswers.count > 1 ? "MULTI" : "MEDIUM",
                       color: AppTheme.V1.Colors.muted,
                       background: AppTheme.V1.Colors.hair)
            }
            .padding(.bottom, 10)

            Text(q.questionText)
                .font(AppTheme.V1.Typography.questionTitle)
                .tracking(-0.2)
                .lineSpacing(2)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 18)

            VStack(spacing: 8) {
                ForEach(Array(q.options.enumerated()), id: \.offset) { idx, option in
                    optionRow(option: option, letter: letter(for: idx), q: q)
                }
            }

            if showExplanation, let explanation = q.explanation {
                explanationCard(text: explanation)
                    .padding(.top, 14)
            }
        }
        .opacity(transitioning ? 0 : 1)
        .offset(x: transitioning ? -10 : 0)
        .animation(.easeOut(duration: 0.2), value: transitioning)
    }

    private func optionRow(option: String, letter: String, q: QuizQuestion) -> some View {
        let isPicked = selectedOptions.contains(option)
        let isAnswer = q.correctAnswers.contains(option)
        let revealed = showNextQuestionButton

        let bg: Color = {
            if revealed {
                if isAnswer { return AppTheme.V1.Colors.successSoft }
                if isPicked { return AppTheme.V1.Colors.dangerSoft }
                return AppTheme.V1.Colors.card
            }
            return isPicked ? AppTheme.V1.Colors.accentSoft : AppTheme.V1.Colors.card
        }()
        let border: Color = {
            if revealed {
                if isAnswer { return AppTheme.V1.Colors.success }
                if isPicked { return AppTheme.V1.Colors.danger }
                return AppTheme.V1.Colors.hair
            }
            return isPicked ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hair
        }()
        let badgeBG: Color = {
            if revealed && isAnswer { return AppTheme.V1.Colors.success }
            if revealed && isPicked { return AppTheme.V1.Colors.danger }
            return isPicked ? AppTheme.V1.Colors.accent : .clear
        }()
        let badgeBorder: Color = {
            if revealed && isAnswer { return AppTheme.V1.Colors.success }
            if revealed && isPicked { return AppTheme.V1.Colors.danger }
            return isPicked ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hairStrong
        }()
        let badgeContent: String = {
            if revealed && isAnswer { return "✓" }
            if revealed && isPicked && !isAnswer { return "✕" }
            if isPicked { return "●" }
            return letter
        }()

        return Button {
            guard !revealed else { return }
            toggleSelection(of: option)
        } label: {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(badgeBG)
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(badgeBorder, lineWidth: 1.5)
                    Text(badgeContent)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(badgeBG == .clear ? AppTheme.V1.Colors.ink : .white)
                }
                .frame(width: 22, height: 22)
                .padding(.top, 1)

                Text(option)
                    .font(AppTheme.V1.Typography.body)
                    .lineSpacing(2)
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .fill(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .stroke(border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(revealed)
    }

    private func explanationCard(text: String) -> some View {
        let bg = isAnswerCorrect ? AppTheme.V1.Colors.successSoft : AppTheme.V1.Colors.dangerSoft
        let accent = isAnswerCorrect ? AppTheme.V1.Colors.success : AppTheme.V1.Colors.danger
        return VStack(alignment: .leading, spacing: 6) {
            Text(isAnswerCorrect ? "✓ CORRECT" : "✕ INCORRECT")
                .font(.system(size: 11, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(accent)
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .lineSpacing(3)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusSm)
                .fill(bg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusSm)
                .stroke(accent.opacity(0.2), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var actionBar: some View {
        let title = showNextQuestionButton
            ? (currentQuestionIndex + 1 >= questions.count ? "See Results" : "Next Question")
            : "Submit"
        return VStack {
            V1Button(
                title: title,
                style: .primary,
                disabled: !showNextQuestionButton && submitButtonDisabled()
            ) {
                if showNextQuestionButton {
                    advanceQuestion()
                } else {
                    if !timerStarted {
                        startTimer()
                        timerStarted = true
                    }
                    checkAnswer()
                }
            }
        }
        .padding(.horizontal, AppTheme.V1.Metrics.pad)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .overlay(
            Rectangle()
                .fill(AppTheme.V1.Colors.hair)
                .frame(height: 1),
            alignment: .top
        )
    }

    // MARK: - Feedback sheet
    private var feedbackSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("We're sorry to hear that. Please help us improve by sharing your feedback.")
                    .multilineTextAlignment(.center)
                    .padding()
                TextEditor(text: $feedbackText)
                    .frame(height: 200)
                    .border(AppTheme.V1.Colors.hair, width: 1)
                    .padding()
                V1Button(title: "Submit Feedback", disabled: feedbackText.isEmpty) {
                    submitFeedback()
                }
                .padding()
            }
            .padding()
            .navigationTitle("Feedback")
            .navigationBarItems(trailing: Button("Cancel") { showFeedbackModal = false })
        }
    }

    // MARK: - Behavior
    private func toggleMark() {
        if marked.contains(currentQuestionIndex) {
            marked.remove(currentQuestionIndex)
        } else {
            marked.insert(currentQuestionIndex)
        }
    }

    private func letter(for idx: Int) -> String {
        guard let scalar = UnicodeScalar(65 + idx) else { return "•" }
        return String(Character(scalar))
    }

    private func submitButtonDisabled() -> Bool {
        guard currentQuestionIndex < questions.count else { return true }
        return selectedOptions.count < questions[currentQuestionIndex].correctAnswers.count
    }

    private func toggleSelection(of option: String) {
        let answersCount = questions[currentQuestionIndex].correctAnswers.count
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else if selectedOptions.count < answersCount {
            selectedOptions.insert(option)
        } else {
            selectedOptions.removeFirst()
            selectedOptions.insert(option)
        }
    }

    private func checkAnswer() {
        let correctAnswers = questions[currentQuestionIndex].correctAnswers
        isAnswerCorrect = Set(correctAnswers) == selectedOptions
        if isAnswerCorrect { correctAnswersCount += 1 }
        withAnimation(.easeOut(duration: 0.3)) {
            showExplanation = true
            showNextQuestionButton = true
        }
    }

    private func advanceQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            transitioning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                currentQuestionIndex += 1
                selectedOptions = []
                showExplanation = false
                showNextQuestionButton = false
                transitioning = false
            }
        } else {
            finishQuiz()
        }
    }

    private func finishQuiz() {
        domainBreakdown = computeDomainBreakdown()
        quizCompleted = true
        stopTimer()

        let percentage = Double(correctAnswersCount) / Double(max(1, questions.count)) * 100
        if percentage >= 70 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showReviewPrompt = true
            }
        }

        let timeSpent = timeLimit - timeRemaining
        let result = QuizResult(
            score: correctAnswersCount,
            totalQuestions: questions.count,
            timeSpent: timeSpent,
            timeLimit: timeLimit
        )
        QuizResultsManager.shared.saveResult(result)
    }

    private func computeDomainBreakdown() -> [(name: String, pct: Int)] {
        let grouped = Dictionary(grouping: questions, by: { $0.category.isEmpty ? "General" : $0.category })
        let overallPct = Double(correctAnswersCount) / Double(max(1, questions.count))
        let pct = Int((overallPct * 100).rounded())
        return grouped
            .map { (name: $0.key, pct: pct) }
            .sorted { $0.pct > $1.pct }
            .prefix(4)
            .map { (name: $0.name, pct: $0.pct) }
    }

    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        quizCompleted = false
        selectedOptions = []
        showExplanation = false
        showNextQuestionButton = false
        showReviewPrompt = false
        userLikedApp = nil
        timeRemaining = timeLimit
        timerStarted = false
        marked.removeAll()
        domainBreakdown.removeAll()
        stopTimer()
    }

    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining < 60 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        pulseOpacity = pulseOpacity > 0.8 ? 0.55 : 1
                    }
                }
            } else {
                finishQuiz()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func toggleTimer() {
        if timerStarted {
            stopTimer()
            timerStarted = false
        } else {
            startTimer()
            timerStarted = true
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func submitFeedback() {
        showFeedbackConfirmation = true
    }
}

// MARK: - Preview
class QuizView_Previews: PreviewProvider {
    static var previews: some View {
        let store = QuizQuestions(setName: "cloud-practitioner-questions")
        let sample = store.getRandomQuizQuestions(count: 5)
        return QuizView(questions: sample, timeLimit: 12 * 60, totalPoolSize: store.getTotalQuizQuestions())
            .environmentObject(ThemeManager())
    }
}
