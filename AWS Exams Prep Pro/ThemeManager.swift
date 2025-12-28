import SwiftUI

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
