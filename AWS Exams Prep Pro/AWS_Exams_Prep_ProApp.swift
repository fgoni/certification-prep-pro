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

    init() {
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
                if hasCompletedOnboarding {
                    LandingScreenView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
        }
        .modelContainer(sharedModelContainer)
    }
}
