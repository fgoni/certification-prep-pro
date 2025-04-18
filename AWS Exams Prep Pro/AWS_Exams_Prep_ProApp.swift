//
//  AWS_Exams_Prep_ProApp.swift
//  AWS Exams Prep Pro
//
//  Created by Facundo Goñi on 11/08/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct AWS_Exams_Prep_ProApp: App {
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
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
