import SwiftUI

// MARK: - Persistence keys
enum OnboardingKey {
    static let hasCompleted = "hasCompletedOnboarding"
    static let userName = "userName"
    static let notificationsEnabled = "notificationsOptIn"
    static let selectedCertRaw = "selectedCertRaw"
}

extension QuestionSet {
    /// Stable string identifier persisted to UserDefaults.
    var rawIdentifier: String {
        switch self {
        case .cloudPractitioner: return "clf"
        case .softwareArchitectAssociate: return "saa"
        case .developerAssociate: return "dev"
        case .sysOpsAssociate: return "soa"
        }
    }

    static func from(rawIdentifier: String) -> QuestionSet? {
        switch rawIdentifier {
        case "clf": return .cloudPractitioner
        case "saa": return .softwareArchitectAssociate
        case "dev": return .developerAssociate
        case "soa": return .sysOpsAssociate
        default: return nil
        }
    }
}

// MARK: - Onboarding root
struct OnboardingView: View {
    @AppStorage(OnboardingKey.hasCompleted) private var hasCompleted: Bool = false
    @AppStorage(OnboardingKey.userName) private var savedName: String = ""
    @AppStorage(OnboardingKey.notificationsEnabled) private var savedNotifPref: Bool = false
    @AppStorage(OnboardingKey.selectedCertRaw) private var savedCertRaw: String = ""

    @State private var step: Int = 0
    @State private var name: String = ""
    @State private var selectedCert: QuestionSet? = nil
    @State private var notifChoice: Bool? = nil
    @State private var direction: CGFloat = 1

    private let totalSteps = 4

    var body: some View {
        ZStack {
            AppTheme.V1.Colors.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar

                stepContent
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .id(step) // forces transition

                actionBar
            }
        }
    }

    // MARK: - Progress bar
    private var progressBar: some View {
        HStack(spacing: 8) {
            if step > 0 && step < totalSteps - 1 {
                Button(action: back) {
                    HStack(spacing: 4) {
                        Path { p in
                            p.move(to: CGPoint(x: 5, y: 1))
                            p.addLine(to: CGPoint(x: 1, y: 5.5))
                            p.addLine(to: CGPoint(x: 5, y: 10))
                        }
                        .stroke(AppTheme.V1.Colors.muted,
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                        .frame(width: 6, height: 11)
                        Text("Back")
                            .font(AppTheme.V1.Typography.label)
                            .foregroundStyle(AppTheme.V1.Colors.muted)
                    }
                    .padding(4)
                }
                .buttonStyle(.plain)
                .frame(width: 60, alignment: .leading)
            } else {
                Color.clear.frame(width: 60, height: 1)
            }

            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hair)
                        .frame(width: i == step ? 22 : 6, height: 4)
                        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.3), value: step)
                }
            }
            .frame(maxWidth: .infinity)

            if step > 0 && step < totalSteps - 1 {
                Button {
                    direction = 1
                    withAnimation(.easeOut(duration: 0.25)) { step = totalSteps - 1 }
                } label: {
                    Text("Skip")
                        .font(AppTheme.V1.Typography.label)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.V1.Colors.muted)
                        .padding(4)
                }
                .buttonStyle(.plain)
                .frame(width: 60, alignment: .trailing)
            } else {
                Color.clear.frame(width: 60, height: 1)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 20)
        .frame(minHeight: 76)
    }

    // MARK: - Step content
    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0:
            OnboardingWelcomeStep()
                .transition(slideTransition)
        case 1:
            OnboardingNameStep(name: $name)
                .transition(slideTransition)
        case 2:
            OnboardingCertStep(selected: $selectedCert)
                .transition(slideTransition)
        default:
            OnboardingNotifStep(name: name, choice: $notifChoice)
                .transition(slideTransition)
        }
    }

    private var slideTransition: AnyTransition {
        let edgeIn: Edge = direction > 0 ? .trailing : .leading
        let edgeOut: Edge = direction > 0 ? .leading : .trailing
        return .asymmetric(
            insertion: .opacity.combined(with: .move(edge: edgeIn)),
            removal: .opacity.combined(with: .move(edge: edgeOut))
        )
    }

    // MARK: - Action bar
    private var actionBar: some View {
        VStack {
            V1Button(title: actionTitle, disabled: actionDisabled, action: handleAction)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 30)
    }

    private var actionTitle: String {
        switch step {
        case 0: return "Get started"
        case 3:
            if notifChoice == false { return "Maybe later" }
            return "Let's go"
        default: return "Continue"
        }
    }

    private var actionDisabled: Bool {
        switch step {
        case 0: return false
        case 1: return name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return selectedCert == nil
        case 3: return notifChoice == nil
        default: return false
        }
    }

    private func handleAction() {
        if step < totalSteps - 1 {
            advance()
        } else {
            finish()
        }
    }

    private func advance() {
        direction = 1
        withAnimation(.easeOut(duration: 0.25)) { step += 1 }
    }

    private func back() {
        direction = -1
        withAnimation(.easeOut(duration: 0.25)) { step = max(0, step - 1) }
    }

    private func finish() {
        savedName = name.trimmingCharacters(in: .whitespaces)
        if let cert = selectedCert {
            savedCertRaw = cert.rawIdentifier
        }
        savedNotifPref = notifChoice ?? false
        hasCompleted = true
    }
}

// MARK: - Step 0: Welcome
private struct OnboardingWelcomeStep: View {
    @State private var animateHero = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 8)

            ZStack {
                // Floating dots
                floatingDot(x: -90, y: -40, size: 10, color: AppTheme.V1.Colors.warn, delay: 0)
                floatingDot(x: 100, y: -10, size: 8, color: AppTheme.V1.Colors.success, delay: 0.8)
                floatingDot(x: 80, y: -52, size: 6, color: Color(hex: "#EC4899"), delay: 1.4)
                floatingDot(x: -90, y: 60, size: 7, color: Color(hex: "#3B82F6"), delay: 2.0)

                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.V1.Colors.accent, Color(hex: "#8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: AppTheme.V1.Colors.accent.opacity(0.35), radius: 24, x: 0, y: 16)
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundStyle(.white)
                    )
                    .offset(y: animateHero ? -3 : 3)
                    .animation(
                        .easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: animateHero
                    )
            }
            .frame(width: 220, height: 130)
            .padding(.bottom, 38)

            Text("Pass your cert.\nBeat the odds.")
                .font(.system(size: 28, weight: .heavy))
                .tracking(-0.7)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .padding(.bottom, 12)

            Text("Realistic practice questions, instant feedback, and a study plan that fits your life.")
                .font(AppTheme.V1.Typography.body)
                .lineSpacing(3)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .padding(.bottom, 32)

            HStack(spacing: 24) {
                trustItem(value: "2,000+", label: "Questions")
                trustItem(value: "4", label: "AWS Certs")
                trustItem(value: "Free", label: "No paywall")
            }

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity)
        .onAppear { animateHero = true }
    }

    private func floatingDot(x: CGFloat, y: CGFloat, size: CGFloat, color: Color, delay: Double) -> some View {
        FloatingDot(size: size, color: color, delay: delay)
            .offset(x: x, y: y)
    }

    private func trustItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .tracking(-0.3)
                .monospacedDigit()
                .foregroundStyle(AppTheme.V1.Colors.ink)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(AppTheme.V1.Colors.muted)
        }
    }
}

private struct FloatingDot: View {
    let size: CGFloat
    let color: Color
    let delay: Double
    @State private var anim = false

    var body: some View {
        Circle()
            .fill(color)
            .opacity(0.9)
            .frame(width: size, height: size)
            .offset(y: anim ? -6 : 0)
            .animation(
                .easeInOut(duration: 3).repeatForever(autoreverses: true).delay(delay),
                value: anim
            )
            .onAppear { anim = true }
    }
}

// MARK: - Step 1: Name
private struct OnboardingNameStep: View {
    @Binding var name: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("STEP 1 OF 3")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.2)
                .foregroundStyle(AppTheme.V1.Colors.accent)
                .padding(.bottom, 10)

            Text("What should we call you?")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
                .lineSpacing(2)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .padding(.bottom, 8)

            Text("We'll use your name to celebrate streaks and milestones.")
                .font(AppTheme.V1.Typography.label)
                .lineSpacing(3)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .padding(.bottom, 28)

            HStack(spacing: 0) {
                ZStack {
                    Circle().fill(AppTheme.V1.Colors.accentSoft)
                    Text(initial)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(AppTheme.V1.Colors.accent)
                }
                .frame(width: 22, height: 22)
                .padding(.leading, 14)

                TextField("Your name", text: $name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .fill(AppTheme.V1.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .stroke(
                        name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? AppTheme.V1.Colors.hair
                            : AppTheme.V1.Colors.accent,
                        lineWidth: 1.5
                    )
            )

            Text("You can change this anytime in settings.")
                .font(AppTheme.V1.Typography.caption)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .padding(.top, 10)
                .padding(.horizontal, 4)

            Spacer(minLength: 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true }
        }
    }

    private var initial: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard let first = trimmed.first else { return "?" }
        return String(first).uppercased()
    }
}

// MARK: - Step 2: Cert
private struct OnboardingCertStep: View {
    @Binding var selected: QuestionSet?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("STEP 2 OF 3")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.2)
                .foregroundStyle(AppTheme.V1.Colors.accent)
                .padding(.bottom, 10)

            Text("Pick your first cert.")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
                .lineSpacing(2)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .padding(.bottom, 8)

            Text("You can switch or add more later — start with what's next.")
                .font(AppTheme.V1.Typography.label)
                .lineSpacing(3)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .padding(.bottom, 22)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(QuestionSet.allCases, id: \.self) { set in
                        certOption(for: set)
                    }
                }
            }
        }
    }

    private func certOption(for set: QuestionSet) -> some View {
        let sel = selected == set
        return Button {
            withAnimation(.easeOut(duration: 0.15)) { selected = set }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [set.brandColor, set.brandColor.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(set.vendor.lowercased())
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(0.4)
                        .foregroundStyle(.white)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(set.shortName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.V1.Colors.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(set.code)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(AppTheme.V1.Colors.muted)
                }
                Spacer()

                ZStack {
                    Circle()
                        .fill(sel ? AppTheme.V1.Colors.accent : Color.clear)
                    Circle()
                        .stroke(sel ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hairStrong, lineWidth: 1.5)
                    if sel {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 22, height: 22)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .fill(sel ? AppTheme.V1.Colors.accentSoft : AppTheme.V1.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radius)
                    .stroke(sel ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hair, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 3: Notifications
private struct OnboardingNotifStep: View {
    let name: String
    @Binding var choice: Bool?

    private var firstName: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "" }
        return String(trimmed.split(separator: " ").first ?? Substring(trimmed))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("STEP 3 OF 3")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.2)
                .foregroundStyle(AppTheme.V1.Colors.accent)
                .padding(.bottom, 10)

            Text(firstName.isEmpty ? "Stay on track?" : "Stay on track, \(firstName)?")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
                .lineSpacing(2)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .padding(.bottom, 8)

            Text("A daily nudge keeps streaks alive — most people pass 2× faster with reminders on.")
                .font(AppTheme.V1.Typography.label)
                .lineSpacing(3)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .padding(.bottom, 22)

            mockNotification
                .padding(.bottom, 20)

            VStack(spacing: 8) {
                notifOption(
                    value: true,
                    title: "Yes, send daily reminders",
                    subtitle: "~7pm, customizable later"
                )
                notifOption(
                    value: false,
                    title: "Not now",
                    subtitle: "You can enable in settings"
                )
            }

            Spacer(minLength: 0)
        }
    }

    private var mockNotification: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.V1.Colors.accent)
                Text("C")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Certification Prep Pro")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.V1.Colors.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Spacer()
                    Text("now")
                        .font(.system(size: 10, weight: .regular))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.V1.Colors.muted)
                }
                Text("Day 13 streak ready 🔥")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                Text("5-minute Quick Quiz to keep it alive.")
                    .font(.system(size: 12.5, weight: .regular))
                    .foregroundStyle(AppTheme.V1.Colors.ink)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.V1.Colors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
        )
        .shadow(color: Color(hex: "#15123B").opacity(0.06), radius: 12, x: 0, y: 6)
    }

    private func notifOption(value: Bool, title: String, subtitle: String) -> some View {
        let sel = choice == value
        return Button {
            withAnimation(.easeOut(duration: 0.15)) { choice = value }
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(sel ? AppTheme.V1.Colors.accent : Color.clear)
                    Circle()
                        .stroke(sel ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hairStrong, lineWidth: 1.5)
                    if sel {
                        Circle()
                            .fill(.white)
                            .frame(width: 7, height: 7)
                    }
                }
                .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.V1.Colors.ink)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(AppTheme.V1.Colors.muted)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusSm)
                    .fill(sel ? AppTheme.V1.Colors.accentSoft : AppTheme.V1.Colors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusSm)
                    .stroke(sel ? AppTheme.V1.Colors.accent : AppTheme.V1.Colors.hair, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Onboarding") {
    OnboardingView()
        .environmentObject(ThemeManager())
}
