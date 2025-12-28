//
//  AWS_Exams_Prep_ProApp.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 11/08/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }

    @AppStorage("selectedTheme") var selectedTheme: Theme = .system {
        didSet {
            applyTheme()
        }
    }

    @Published var colorScheme: ColorScheme?

    init() {
        applyTheme()
    }

    func applyTheme() {
        switch selectedTheme {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        case .system:
            colorScheme = nil
        }
    }

    func toggleTheme() {
        switch selectedTheme {
        case .light:
            selectedTheme = .dark
        case .dark:
            selectedTheme = .system
        case .system:
            selectedTheme = .light
        }
    }

    func setTheme(_ theme: Theme) {
        selectedTheme = theme
    }
}

@main
struct AWS_Exams_Prep_ProApp: App {
    @StateObject private var themeManager = ThemeManager()

    init() {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                LandingScreenView()
                    .environmentObject(themeManager)
            }
            .preferredColorScheme(themeManager.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
