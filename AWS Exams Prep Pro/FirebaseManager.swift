import Foundation
#if canImport(FirebaseCore)
import FirebaseCore
#endif

/// Manages Firebase initialization and configuration
class FirebaseManager {
    static let shared = FirebaseManager()

    private var isInitialized = false

    private init() {}

    /// Initialize Firebase - call this at app startup
    func initialize() {
        guard !isInitialized else { return }

        #if canImport(FirebaseCore)
        // Configure Firebase with GoogleService-Info.plist
        FirebaseApp.configure()
        isInitialized = true
        print("✅ Firebase initialized successfully")
        #else
        print("⚠️ Firebase SDK not available. Skipping initialization.")
        #endif
    }
}
