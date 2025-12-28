//
//  AppTheme.swift
//  AWS Exams Prep Pro
//
//  Central theme configuration for colors, spacing, and typography
//

import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        // Primary accent colors
        static let primary = Color.blue
        static let secondary = Color.orange

        // Status/semantic colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        // Background colors (adaptive)
        static let backgroundPrimary = Color.adaptive(
            light: .white,
            dark: Color(hex: "#121212")
        )
        static let backgroundSecondary = Color.adaptive(
            light: Color(hex: "#F2F2F7"),
            dark: Color(hex: "#0A0A0A")
        )

        // Neutral colors
        static let background = Color(.systemBackground)
        static let surface = Color(.systemGray6)
        static let surfaceRaised = Color(.systemGray5)

        // Card colors (adaptive)
        static let cardBackground = Color.adaptive(
            light: .white,
            dark: Color(hex: "#1C1C1E")
        )
        static let actionCardBackground = Color.adaptive(
            light: Color(hex: "#F2F2F7"),
            dark: Color(hex: "#1C1C1E")
        )
        static let actionCardBorder = Color.adaptive(
            light: .clear,
            dark: Color(hex: "#3A3A3C")
        )

        // Status card colors - Credits (adaptive)
        static let creditsCardBackground = Color.adaptive(
            light: Color(hex: "#FFF5E6"),
            dark: Color(hex: "#2C2416")
        )
        static let creditsCardText = Color.adaptive(
            light: Color(hex: "#CC5200"),
            dark: Color(hex: "#FFB366")
        )
        static let creditsIconColor = Color.adaptive(
            light: Color(hex: "#FF8000"),
            dark: Color(hex: "#FF9933")
        )
        static let creditsIconBackground = Color.adaptive(
            light: .white,
            dark: Color(hex: "#2C2C2E")
        )

        // Status card colors - Timer (adaptive)
        static let timerCardBackground = Color.adaptive(
            light: Color(hex: "#F0F5FF"),
            dark: Color(hex: "#1A1F2E")
        )
        static let timerCardText = Color.adaptive(
            light: Color(hex: "#1A5AFF"),
            dark: Color(hex: "#5C9EFF")
        )
        static let timerIconColor = Color.adaptive(
            light: Color(hex: "#3366FF"),
            dark: Color(hex: "#4D8AFF")
        )
        static let timerIconBackground = Color.adaptive(
            light: .white,
            dark: Color(hex: "#2C2C2E")
        )

        // Text colors (adaptive)
        static let textPrimary = Color.adaptive(
            light: .black,
            dark: .white
        )
        static let textSecondary = Color.adaptive(
            light: Color(hex: "#666666"),
            dark: Color(hex: "#8E8E93")
        )
        static let textTertiary = Color(.tertiaryLabel)

        // Component-specific colors
        static let creditsBackground = Color.orange
        static let timerBackground = Color.blue
        static let passBadgeBackground = Color.green
        static let failBadgeBackground = Color.red

        // Accent colors
        static let accentBlue = Color(hex: "#3366FF")
        static let examSelectorBackground = Color(hex: "#3366FF")

        // Icon colors
        static let iconPrimary = Color(.systemFill)
        static let iconSecondary = Color(.secondarySystemFill)
    }

    // MARK: - Spacing
    enum Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let massive: CGFloat = 24
    }

    // MARK: - Typography
    enum Typography {
        // System Font Presets
        static let largeTitle = Font.largeTitle
        static let title1 = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let caption = Font.caption
        static let caption2 = Font.caption2

        // Landing Screen Typography
        static let landingMainTitle = Font.system(size: 22, weight: .bold)
        static let landingSubtitle = Font.system(size: 14, weight: .regular)

        // Status Card Typography
        static let statusCardLabel = Font.system(size: 10, weight: .semibold)
        static let statusCardValue = Font.system(size: 16, weight: .bold)

        // Action Card Typography
        static let actionCardTitle = Font.system(size: 16, weight: .semibold)
        static let actionCardSubtitle = Font.system(size: 12, weight: .regular)

        // General Card Typography
        static let cardTitle = Font.system(size: 16, weight: .semibold)
        static let cardSubtitle = Font.system(size: 12, weight: .regular)

        // Custom font sizes with weights
        static func systemFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight)
        }
    }

    // MARK: - Metrics
    enum Metrics {
        // Corner radius
        static let cornerRadiusSmall: CGFloat = 8
        static let cornerRadiusMedium: CGFloat = 12
        static let cornerRadiusLarge: CGFloat = 16

        // Card metrics
        static let cardPaddingHorizontal = Spacing.large
        static let cardPaddingVertical = Spacing.medium
        static let cardCornerRadius = cornerRadiusMedium

        // Button metrics
        static let buttonHeightSmall: CGFloat = 36
        static let buttonHeightMedium: CGFloat = 44
        static let buttonHeightLarge: CGFloat = 52
        static let buttonCornerRadius = cornerRadiusMedium

        // Icon metrics
        static let iconSizeSmall: CGFloat = 12
        static let iconSizeMedium: CGFloat = 16
        static let iconSizeLarge: CGFloat = 20
        static let iconSizeExtraLarge: CGFloat = 36
    }
}
