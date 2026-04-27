import SwiftUI

/// Theme toggle button for switching between light/dark/system modes
struct ThemeToggleButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme

    private var iconName: String {
        switch themeManager.selectedTheme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.toggleTheme()
            }
        }) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.V1.Colors.ink)
                .frame(width: 30, height: 30)
                .background(
                    Circle().fill(AppTheme.V1.Colors.card)
                )
                .overlay(
                    Circle().stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
                )
        }
    }
}

/// Landing screen — V1 Refined.
struct LandingScreenView: View {
    @StateObject private var viewModel: LandingViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var certPickerOpen: Bool = false
    @State private var profileOpen: Bool = false
    @AppStorage(OnboardingKey.userName) private var userName: String = ""

    init(
        quizLimitProvider: any QuizLimitProviderProtocol = QuizLimitManager.shared,
        adProvider: any AdProviderProtocol = AdManager.shared
    ) {
        _viewModel = StateObject(wrappedValue: LandingViewModel(
            quizLimitProvider: quizLimitProvider,
            adProvider: adProvider
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppTheme.V1.Colors.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        heroHeader
                        VStack(alignment: .leading, spacing: AppTheme.V1.Metrics.gap + 6) {
                            certSelectorCard
                            readinessCard
                            practiceSection
                            weekSection
                            footerNote
                        }
                        .padding(.horizontal, AppTheme.V1.Metrics.pad)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.isFullQuizActive) {
                QuizView(
                    questions: Array(viewModel.quizData.allQuizQuestions.shuffled().prefix(65)),
                    timeLimit: 40 * 60,
                    totalPoolSize: viewModel.quizData.getTotalQuizQuestions()
                )
            }
            .navigationDestination(isPresented: $viewModel.isQuickQuizActive) {
                QuizView(
                    questions: Array(viewModel.quizData.allQuizQuestions.shuffled().prefix(20)),
                    timeLimit: 12 * 60,
                    totalPoolSize: viewModel.quizData.getTotalQuizQuestions()
                )
            }
            .alert("Watch an Ad to Unlock More Quizzes", isPresented: $viewModel.showAdAlert) {
                Button("Watch Ad") { viewModel.watchAdToUnlock() }
                Button("Cancel", role: .cancel) { viewModel.showAdAlert = false }
            } message: {
                Text("Watch a short ad to get an additional quiz attempt.")
            }
            .sheet(isPresented: $viewModel.showExamSelector) {
                ExamSelectorView(
                    selectedExam: $viewModel.selectedQuestionSet,
                    isPresented: $viewModel.showExamSelector
                )
            }
            .sheet(isPresented: $profileOpen) {
                ProfileView()
                    .environmentObject(themeManager)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: viewModel.selectedQuestionSet) { _, newValue in
                viewModel.changeQuestionSet(to: newValue)
            }
        }
    }

    // MARK: - Hero
    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if currentStreak > 0 {
                    streakBadge
                }
                HStack {
                    Spacer()
                    profileAvatarButton
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)

            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.V1.Colors.accent)
                    Text("C")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(.white)
                }
                .frame(width: 26, height: 26)

                Text("Certification Prep Pro")
                    .font(AppTheme.V1.Typography.bodyEmphasis)
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer()
            }
            .padding(.bottom, 14)

            Text(greeting)
                .font(AppTheme.V1.Typography.small)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .padding(.bottom, 4)

            Text("Ready for your\n\(viewModel.selectedQuestionSet.vendor) \(viewModel.selectedQuestionSet.shortName)?")
                .font(AppTheme.V1.Typography.display)
                .tracking(-0.4)
                .lineSpacing(2)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppTheme.V1.Metrics.pad + 4)
        .padding(.top, 56)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppTheme.V1.Colors.bgHero, AppTheme.V1.Colors.bg],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var profileAvatarButton: some View {
        Button(action: { profileOpen = true }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.V1.Colors.accent, Color(hex: "#8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(profileInitial)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .frame(width: 30, height: 30)
            .overlay(
                Circle().stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var profileInitial: String {
        let trimmed = userName.trimmingCharacters(in: .whitespaces)
        guard let first = trimmed.first else { return "?" }
        return String(first).uppercased()
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "Good morning"
        case 12..<18: timeOfDay = "Good afternoon"
        default: timeOfDay = "Good evening"
        }
        let trimmed = userName.trimmingCharacters(in: .whitespaces)
        let first = String(trimmed.split(separator: " ").first ?? Substring(trimmed))
        return first.isEmpty ? "\(timeOfDay)" : "\(timeOfDay), \(first)"
    }

    private var currentStreak: Int {
        QuizResultsManager.shared.currentStreak()
    }

    @ViewBuilder
    private var streakBadge: some View {
        let streak = currentStreak
        if streak > 0 {
            HStack(spacing: 4) {
                Circle()
                    .fill(AppTheme.V1.Colors.warn)
                    .frame(width: 7, height: 7)
                Text("\(streak)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                    .monospacedDigit()
                Text(streak == 1 ? "day streak" : "day streak")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.V1.Colors.muted)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(AppTheme.V1.Colors.card.opacity(0.7))
            )
            .overlay(
                Capsule().stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
            )
        }
    }

    // MARK: - Cert selector
    private var certSelectorCard: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) { certPickerOpen.toggle() }
            } label: {
                HStack(spacing: 12) {
                    certBadge(for: viewModel.selectedQuestionSet, large: true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.selectedQuestionSet.shortName)
                            .font(AppTheme.V1.Typography.smallEmphasis)
                            .foregroundStyle(AppTheme.V1.Colors.ink)
                        Text("\(viewModel.selectedQuestionSet.code) · \(viewModel.quizData.allQuizQuestions.count) questions")
                            .font(AppTheme.V1.Typography.caption)
                            .foregroundStyle(AppTheme.V1.Colors.muted)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.V1.Colors.muted)
                        .rotationEffect(.degrees(certPickerOpen ? 180 : 0))
                }
                .padding(12)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusLg)
                    .fill(AppTheme.V1.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusLg)
                    .stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
            )

            if certPickerOpen {
                VStack(spacing: 0) {
                    let others = QuestionSet.allCases.filter { $0 != viewModel.selectedQuestionSet }
                    ForEach(Array(others.enumerated()), id: \.offset) { idx, set in
                        Button {
                            viewModel.changeQuestionSet(to: set)
                            withAnimation(.easeOut(duration: 0.2)) { certPickerOpen = false }
                        } label: {
                            HStack(spacing: 10) {
                                certBadge(for: set, large: false)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(set.shortName)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(AppTheme.V1.Colors.ink)
                                    Text(set.code)
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(AppTheme.V1.Colors.muted)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        if idx < others.count - 1 {
                            Rectangle()
                                .fill(AppTheme.V1.Colors.hair)
                                .frame(height: 1)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusLg)
                        .fill(AppTheme.V1.Colors.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusLg)
                        .stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
                )
                .padding(.top, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func certBadge(for set: QuestionSet, large: Bool) -> some View {
        let size: CGFloat = large ? 40 : 28
        return ZStack {
            RoundedRectangle(cornerRadius: large ? 10 : 7)
                .fill(
                    LinearGradient(
                        colors: [set.brandColor, set.brandColor.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(set.vendor.lowercased())
                .font(.system(size: large ? 11 : 9, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }

    // MARK: - Readiness
    private var readinessCard: some View {
        V1Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    V1SectionLabel(text: "Readiness")
                    Spacer()
                    if let pct = readinessPercent {
                        Text(pct >= 75 ? "ON TRACK" : "WORK NEEDED")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.2)
                            .foregroundStyle(pct >= 75 ? AppTheme.V1.Colors.success : AppTheme.V1.Colors.warn)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(pct >= 75 ? AppTheme.V1.Colors.successSoft : AppTheme.V1.Colors.accentSoft)
                            )
                    }
                }
                if let pct = readinessPercent {
                    readinessFilled(pct: pct)
                } else {
                    readinessEmpty
                }
            }
        }
    }

    private func readinessFilled(pct: Int) -> some View {
        HStack(alignment: .bottom, spacing: 12) {
            V1Ring(pct: Double(pct), size: 52, stroke: 6, color: AppTheme.V1.Colors.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(pct)%")
                    .font(AppTheme.V1.Typography.scoreMedium)
                    .tracking(-0.5)
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                    .monospacedDigit()
                Text("Last 5 quizzes")
                    .font(AppTheme.V1.Typography.caption)
                    .foregroundStyle(AppTheme.V1.Colors.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Target")
                    .font(AppTheme.V1.Typography.caption)
                    .foregroundStyle(AppTheme.V1.Colors.muted)
                Text("75%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.V1.Colors.ink)
            }
        }
    }

    private var readinessEmpty: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .stroke(AppTheme.V1.Colors.hair, lineWidth: 6)
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(AppTheme.V1.Colors.muted.opacity(0.7))
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text("No data yet")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                Text("Take a quiz to see your readiness.")
                    .font(AppTheme.V1.Typography.caption)
                    .foregroundStyle(AppTheme.V1.Colors.muted)
            }
            Spacer()
        }
    }

    /// Returns nil if there are no results; otherwise the average % of the last 5 quizzes.
    private var readinessPercent: Int? {
        let recent = QuizResultsManager.shared.fetchResults().suffix(5)
        guard !recent.isEmpty else { return nil }
        let avg = recent.map { $0.percentage }.reduce(0, +) / Double(recent.count)
        return Int(avg.rounded())
    }

    // MARK: - Practice modes
    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            V1SectionLabel(text: "Practice")
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                practiceRow(
                    title: "Full Quiz",
                    subtitle: "65 Questions · 90 min",
                    glyph: "diamond.fill",
                    color: AppTheme.V1.Colors.accent,
                    showDivider: true
                ) { viewModel.startFullQuiz() }

                practiceRow(
                    title: "Quick Quiz",
                    subtitle: "20 Questions · 12 min",
                    glyph: "diamond",
                    color: AppTheme.V1.Colors.success,
                    showDivider: false
                ) { viewModel.startQuickQuiz() }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusLg)
                    .fill(AppTheme.V1.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusLg)
                    .stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
            )
        }
    }

    private func practiceRow(
        title: String,
        subtitle: String,
        glyph: String,
        color: Color,
        showDivider: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.12))
                        Image(systemName: glyph)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(color)
                    }
                    .frame(width: 34, height: 34)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(AppTheme.V1.Typography.bodyEmphasis)
                            .foregroundStyle(AppTheme.V1.Colors.ink)
                        Text(subtitle)
                            .font(AppTheme.V1.Typography.caption)
                            .foregroundStyle(AppTheme.V1.Colors.muted)
                    }
                    Spacer()
                    V1Chevron()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, AppTheme.V1.Metrics.row - 2)

                if showDivider {
                    Rectangle()
                        .fill(AppTheme.V1.Colors.hair)
                        .frame(height: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Week chart
    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                V1SectionLabel(text: "This week")
                Spacer()
                if QuizResultsManager.shared.fetchResults().isEmpty == false {
                    NavigationLink(destination: HistoricalResultsView()) {
                        Text("See all →")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppTheme.V1.Colors.accent)
                    }
                }
            }
            .padding(.horizontal, 4)

            V1Card {
                if QuizResultsManager.shared.fetchResults().isEmpty {
                    weekEmptyState
                } else {
                    weekBars
                }
            }
        }
    }

    private var weekBars: some View {
        let labels = ["M","T","W","T","F","S","S"]
        let heights: [CGFloat] = weeklyHeights
        let todayIndex = todayIndexInWeek
        return HStack(alignment: .bottom, spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor(for: i, today: todayIndex == i, height: heights[i]))
                        .frame(width: 14, height: max(4, heights[i]))
                    Text(labels[i])
                        .font(.system(size: 10, weight: todayIndex == i ? .bold : .medium))
                        .foregroundStyle(todayIndex == i ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.muted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 80, alignment: .bottom)
    }

    private var weekEmptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(AppTheme.V1.Colors.muted.opacity(0.6))
            Text("No quizzes yet this week")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.V1.Colors.ink)
            Text("Take your first quiz to start tracking progress.")
                .font(AppTheme.V1.Typography.caption)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func barColor(for i: Int, today: Bool, height: CGFloat) -> Color {
        if today { return AppTheme.V1.Colors.accent }
        if height > 4 { return AppTheme.V1.Colors.accent.opacity(0.4) }
        return AppTheme.V1.Colors.hair
    }

    private var todayIndexInWeek: Int {
        // Mon = 0 ... Sun = 6
        let weekday = Calendar.current.component(.weekday, from: Date()) // 1=Sun … 7=Sat
        return (weekday + 5) % 7
    }

    private var weeklyHeights: [CGFloat] {
        // Last 7 calendar days, latest = today. Map percentage → height [0,60].
        let now = Date()
        let cal = Calendar.current
        let results = QuizResultsManager.shared.fetchResults()
        var byDay: [Int: Double] = [:]
        for r in results {
            if let days = cal.dateComponents([.day], from: cal.startOfDay(for: r.date), to: cal.startOfDay(for: now)).day,
               days >= 0, days < 7 {
                byDay[days] = max(byDay[days] ?? 0, r.percentage)
            }
        }
        let today = todayIndexInWeek
        var heights: [CGFloat] = Array(repeating: 0, count: 7)
        for daysAgo in 0..<7 {
            let idx = (today - daysAgo + 7) % 7
            let pct = byDay[daysAgo] ?? 0
            heights[idx] = pct > 0 ? CGFloat(pct / 100.0) * 60 : 0
        }
        return heights
    }

    // MARK: - Footer
    private var footerNote: some View {
        VStack(spacing: 6) {
            Text("v\(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
                .font(.caption2)
                .foregroundStyle(AppTheme.V1.Colors.muted.opacity(0.6))
            Link(destination: URL(string: "https://coffeedevs.com")!) {
                Text("Built with ❤️ by coffeedevs.com")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.V1.Colors.muted.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
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
