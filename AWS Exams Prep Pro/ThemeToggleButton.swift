import SwiftUI

struct ThemeToggleButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme

    private var currentScheme: ColorScheme {
        themeManager.colorScheme ?? systemColorScheme
    }

    private var iconName: String {
        switch currentScheme {
        case .light:
            return "moon.fill"
        case .dark:
            return "sun.max.fill"
        @unknown default:
            return "circle.lefthalf.filled"
        }
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.toggleTheme()
            }
        }) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: 44, height: 44)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(Circle())
                .shadow(
                    color: Color.black.opacity(currentScheme == .dark ? 0.3 : 0.1),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            ThemeToggleButton()
                .padding(.trailing, 16)
                .padding(.bottom, 16)
        }
    }
    .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
    .environmentObject(ThemeManager())
}
