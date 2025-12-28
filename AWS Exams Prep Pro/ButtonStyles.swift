//
//  ButtonStyles.swift
//  AWS Exams Prep Pro
//
//  Custom button styles for the app
//

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Metrics.buttonHeightMedium)
            .background(AppTheme.Colors.primary)
            .cornerRadius(AppTheme.Metrics.buttonCornerRadius)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppTheme.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Metrics.buttonHeightMedium)
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.Metrics.buttonCornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Plain Button Style (for cards and minimal buttons)
struct PlainCardButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed && isEnabled ? 0.8 : 1.0)
    }
}

// MARK: - Extensions for easy usage
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle {
        SecondaryButtonStyle()
    }
}

extension ButtonStyle where Self == PlainCardButtonStyle {
    static var plainCard: PlainCardButtonStyle {
        PlainCardButtonStyle()
    }
}
