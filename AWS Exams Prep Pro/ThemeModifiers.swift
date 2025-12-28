//
//  ThemeModifiers.swift
//  AWS Exams Prep Pro
//
//  Common view modifiers for consistent styling
//

import SwiftUI

// MARK: - Card Modifier
struct CardModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let padding: EdgeInsets

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .padding(padding)
    }
}

// MARK: - Status Card Modifier
struct StatusCardModifier: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(backgroundColor)
            .cornerRadius(AppTheme.Metrics.cardCornerRadius)
    }
}

// MARK: - Action Card Modifier
struct ActionCardModifier: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.vertical, AppTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .cornerRadius(AppTheme.Metrics.cardCornerRadius)
    }
}

// MARK: - View Extensions
extension View {
    /// Apply standard card styling
    func cardStyle(
        backgroundColor: Color = AppTheme.Colors.surface,
        cornerRadius: CGFloat = AppTheme.Metrics.cardCornerRadius,
        padding: EdgeInsets = .init(
            top: AppTheme.Spacing.medium,
            leading: AppTheme.Spacing.large,
            bottom: AppTheme.Spacing.medium,
            trailing: AppTheme.Spacing.large
        )
    ) -> some View {
        modifier(CardModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }

    /// Apply status card styling (for quiz limit, credits, etc.)
    func statusCardStyle(backgroundColor: Color) -> some View {
        modifier(StatusCardModifier(backgroundColor: backgroundColor))
    }

    /// Apply action card styling (for quiz buttons, navigation cards)
    func actionCardStyle(backgroundColor: Color = AppTheme.Colors.surface) -> some View {
        modifier(ActionCardModifier(backgroundColor: backgroundColor))
    }

    /// Apply standard padding
    func themePadding(_ edges: Edge.Set = .all, _ amount: CGFloat = AppTheme.Spacing.large) -> some View {
        padding(edges, amount)
    }

    /// Apply standard spacing
    func themeSpacing(_ spacing: CGFloat = AppTheme.Spacing.large) -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, spacing)
    }

    /// Apply primary text styling
    func primaryTextStyle(size: CGFloat = 17) -> some View {
        font(.system(size: size, weight: .semibold))
            .foregroundColor(AppTheme.Colors.textPrimary)
    }

    /// Apply secondary text styling
    func secondaryTextStyle(size: CGFloat = 14) -> some View {
        font(.system(size: size, weight: .regular))
            .foregroundColor(AppTheme.Colors.textSecondary)
    }

    /// Apply heading styling
    func headingStyle() -> some View {
        font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppTheme.Colors.textPrimary)
    }

    /// Apply subheading styling
    func subheadingStyle() -> some View {
        font(.system(size: 14, weight: .regular))
            .foregroundColor(AppTheme.Colors.textSecondary)
    }

    /// Apply disabled state styling
    func disabledOpacity(_ isDisabled: Bool) -> some View {
        opacity(isDisabled ? 0.5 : 1.0)
    }
}
