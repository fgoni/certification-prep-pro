//
//  AWS_Exams_Prep_ProApp.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 11/08/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct AWS_Exams_Prep_ProApp: App {
    @StateObject private var themeManager = ThemeManager()
    @AppStorage(OnboardingKey.hasCompleted) private var hasCompletedOnboarding: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    init() {
        #if DEBUG
        ScreenshotHarness.prepareIfNeeded()
        #endif

        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)

        // Initialize Firebase
        // FirebaseManager.shared.initialize()
        // Note: Firebase packages will be added via Swift Package Manager
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                #if DEBUG
                if let route = ScreenshotHarness.requestedRoute {
                    ScreenshotHarnessView(route: route)
                } else if hasCompletedOnboarding {
                    LandingScreenView()
                } else {
                    OnboardingView()
                }
                #else
                if hasCompletedOnboarding {
                    LandingScreenView()
                } else {
                    OnboardingView()
                }
                #endif
            }
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
            .task { await NotificationManager.shared.refreshSchedule() }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await NotificationManager.shared.refreshSchedule() }
            }
        }
    }
}

#if DEBUG
private enum ScreenshotRoute: String {
    case home
    case fullQuiz
    case quickQuiz
    case result
    case history
}

private enum ScreenshotHarness {
    static var requestedRoute: ScreenshotRoute? {
        let args = ProcessInfo.processInfo.arguments
        guard args.contains("-appStoreScreenshot"),
              let index = args.firstIndex(of: "-screenshotRoute"),
              args.indices.contains(index + 1) else {
            return nil
        }
        return ScreenshotRoute(rawValue: args[index + 1])
    }

    static func prepareIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("-appStoreScreenshot") else { return }

        let defaults = UserDefaults.standard
        defaults.set(true, forKey: OnboardingKey.hasCompleted)
        defaults.set("Alex", forKey: OnboardingKey.userName)
        defaults.set(QuestionSet.softwareArchitectAssociate.rawIdentifier, forKey: OnboardingKey.selectedCertRaw)
        defaults.set("Light", forKey: "selectedTheme")
        defaults.set(3, forKey: QuizLimitConfiguration.default.remainingAttemptsKey)
        defaults.set(Date(), forKey: QuizLimitConfiguration.default.lastResetDateKey)
        defaults.removeObject(forKey: "quizResults")

        [
            QuizResult(score: 18, totalQuestions: 20, timeSpent: 9 * 60 + 18, timeLimit: 12 * 60),
            QuizResult(score: 52, totalQuestions: 65, timeSpent: 61 * 60 + 42, timeLimit: 90 * 60),
            QuizResult(score: 16, totalQuestions: 20, timeSpent: 10 * 60 + 5, timeLimit: 12 * 60),
            QuizResult(score: 43, totalQuestions: 65, timeSpent: 68 * 60 + 11, timeLimit: 90 * 60)
        ].forEach { QuizResultsManager.shared.saveResult($0) }
    }
}

private struct ScreenshotHarnessView: View {
    let route: ScreenshotRoute

    var body: some View {
        switch route {
        case .home:
            LandingScreenView()
        case .fullQuiz:
            QuizView(
                questions: sampleQuestions(count: 65),
                timeLimit: 90 * 60,
                totalPoolSize: quizStore.getTotalQuizQuestions()
            )
        case .quickQuiz:
            QuizView(
                questions: sampleQuestions(count: 20),
                timeLimit: 12 * 60,
                totalPoolSize: quizStore.getTotalQuizQuestions()
            )
        case .result:
            ResultView(
                score: 18,
                total: 20,
                timeSpent: 9 * 60 + 18,
                breakdown: [
                    ("Compute", 92),
                    ("Storage", 86),
                    ("Security", 80),
                    ("Pricing", 74)
                ],
                onHome: {},
                onRestart: {}
            )
        case .history:
            HistoricalResultsView()
        }
    }

    private var quizStore: QuizQuestions {
        QuizQuestions(setName: "software-architect-associate-questions")
    }

    private func sampleQuestions(count: Int) -> [QuizQuestion] {
        Array(quizStore.allQuizQuestions.prefix(count))
    }
}
#endif
