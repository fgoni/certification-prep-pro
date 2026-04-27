import SwiftUI

/// Small profile / settings sheet — edit name, toggle notifications, adjust theme.
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @AppStorage(OnboardingKey.userName) private var userName: String = ""
    @AppStorage(OnboardingKey.notificationsEnabled) private var notificationsEnabled: Bool = false

    @State private var draftName: String = ""
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.V1.Colors.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.V1.Metrics.gap + 6) {
                        avatarHeader
                        nameField
                        preferencesCard
                        Spacer(minLength: 12)
                    }
                    .padding(.horizontal, AppTheme.V1.Metrics.pad)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        commit()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.V1.Colors.accent)
                }
            }
        }
        .onAppear { draftName = userName }
    }

    // MARK: - Avatar header
    private var avatarHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.V1.Colors.accent, Color(hex: "#8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(initial)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .frame(width: 72, height: 72)
            .shadow(color: AppTheme.V1.Colors.accent.opacity(0.25), radius: 16, x: 0, y: 8)

            Text(displayName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppTheme.V1.Colors.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var initial: String {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        guard let first = trimmed.first else { return "?" }
        return String(first).uppercased()
    }

    private var displayName: String {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Your name" : trimmed
    }

    // MARK: - Name field
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            V1SectionLabel(text: "Name")
                .padding(.horizontal, 4)

            HStack(spacing: 0) {
                TextField("Your name", text: $draftName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($nameFocused)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .fill(AppTheme.V1.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .stroke(
                        nameFocused ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hair,
                        lineWidth: 1.5
                    )
            )
        }
    }

    // MARK: - Preferences
    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            V1SectionLabel(text: "Preferences")
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                preferenceRow(
                    icon: "bell.fill",
                    iconColor: AppTheme.V1.Colors.warn,
                    title: "Daily reminders",
                    subtitle: notificationsEnabled ? "On — keeps your streak alive" : "Off",
                    showDivider: true
                ) {
                    Toggle("", isOn: notificationsBinding)
                        .labelsHidden()
                        .tint(AppTheme.V1.Colors.accent)
                }

                preferenceRow(
                    icon: themeIcon,
                    iconColor: AppTheme.V1.Colors.accent,
                    title: "Appearance",
                    subtitle: themeLabel,
                    showDivider: false
                ) {
                    Menu {
                        Picker("Theme", selection: themeBinding) {
                            ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(themeManager.selectedTheme.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.V1.Colors.muted)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppTheme.V1.Colors.muted)
                        }
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
        }
    }

    private func preferenceRow<Trailing: View>(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showDivider: Bool,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.12))
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(iconColor)
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
                trailing()
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

    private var themeIcon: String {
        switch themeManager.selectedTheme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    private var themeLabel: String {
        switch themeManager.selectedTheme {
        case .light: return "Always light"
        case .dark: return "Always dark"
        case .system: return "Match system"
        }
    }

    private var themeBinding: Binding<ThemeManager.Theme> {
        Binding(
            get: { themeManager.selectedTheme },
            set: { themeManager.setTheme($0) }
        )
    }

    // MARK: - Actions
    private func commit() {
        userName = draftName.trimmingCharacters(in: .whitespaces)
    }

    /// Wraps the @AppStorage binding so we can request system authorization
    /// when the user flips the toggle on, and clear pending reminders when
    /// they flip it off.
    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { notificationsEnabled },
            set: { newValue in
                notificationsEnabled = newValue
                Task {
                    if newValue {
                        let granted = await NotificationManager.shared.requestAuthorization()
                        if granted {
                            await NotificationManager.shared.refreshSchedule()
                        } else {
                            // System prompt was denied (or previously denied) —
                            // bounce the toggle back so we don't lie about state.
                            await MainActor.run { notificationsEnabled = false }
                            await NotificationManager.shared.cancelAll()
                        }
                    } else {
                        await NotificationManager.shared.cancelAll()
                    }
                }
            }
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager())
}
