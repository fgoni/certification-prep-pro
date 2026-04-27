import SwiftUI

/// V1 Refined result screen — pass/fail header, animated score ring, domain breakdown.
struct ResultView: View {
    let score: Int
    let total: Int
    let timeSpent: Int
    let breakdown: [(name: String, pct: Int)]
    let onHome: () -> Void
    let onRestart: () -> Void

    @State private var animPct: Double = 0

    private var pct: Int {
        guard total > 0 else { return 0 }
        return Int((Double(score) / Double(total) * 100).rounded())
    }

    private var passed: Bool { pct >= 75 }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(passed ? "YOU PASSED" : "KEEP GOING")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(passed ? AppTheme.V1.Colors.success : AppTheme.V1.Colors.danger)
                    .padding(.bottom, 14)

                scoreRing
                    .padding(.bottom, 24)

                Text("\(score) of \(total) correct")
                    .font(AppTheme.V1.Typography.body)
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.V1.Colors.muted)
                    .padding(.bottom, 4)

                Text("Pass mark: 75% · Time: \(formatTime(timeSpent))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.V1.Colors.muted)
                    .padding(.bottom, 28)

                if !breakdown.isEmpty {
                    domainCard
                }

                Spacer(minLength: 12)
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 10) {
                V1Button(title: "Home", style: .secondary, action: onHome)
                V1Button(title: "Try again", style: .primary, action: onRestart)
            }
        }
        .padding(.horizontal, AppTheme.V1.Metrics.pad)
        .padding(.top, 52)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.V1.Colors.bg.ignoresSafeArea())
    }

    // MARK: - Ring
    private var scoreRing: some View {
        let size: CGFloat = 180
        let stroke: CGFloat = 14
        return ZStack {
            Circle()
                .stroke(AppTheme.V1.Colors.hair, lineWidth: stroke)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(animPct, 0), 100) / 100))
                .stroke(
                    passed ? AppTheme.V1.Colors.success : AppTheme.V1.Colors.danger,
                    style: StrokeStyle(lineWidth: stroke, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(Int(animPct.rounded()))%")
                    .font(AppTheme.V1.Typography.scoreNumber)
                    .tracking(-2)
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                Text("SCORE")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(AppTheme.V1.Colors.muted)
                    .padding(.top, 2)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1.4).delay(0.1)) {
                animPct = Double(pct)
            }
        }
    }

    // MARK: - Domain breakdown
    private var domainCard: some View {
        V1Card {
            VStack(alignment: .leading, spacing: 0) {
                V1SectionLabel(text: "By Domain")
                    .padding(.bottom, 10)
                VStack(spacing: 0) {
                    ForEach(Array(breakdown.enumerated()), id: \.offset) { _, row in
                        domainRow(name: row.name, pct: row.pct)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
    }

    private func domainRow(name: String, pct: Int) -> some View {
        HStack(spacing: 10) {
            Text(name)
                .font(AppTheme.V1.Typography.small)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.V1.Colors.ink)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppTheme.V1.Colors.hair)
                    Capsule()
                        .fill(barColor(pct: pct))
                        .frame(width: CGFloat(pct) / 100 * geo.size.width)
                        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1.0), value: animPct)
                }
            }
            .frame(height: 4)

            Text("\(pct)%")
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .frame(width: 32, alignment: .trailing)
        }
    }

    private func barColor(pct: Int) -> Color {
        if pct >= 75 { return AppTheme.V1.Colors.success }
        if pct >= 50 { return AppTheme.V1.Colors.warn }
        return AppTheme.V1.Colors.danger
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    ResultView(
        score: 16,
        total: 20,
        timeSpent: 222,
        breakdown: [
            ("Compute", 100),
            ("Storage", 100),
            ("Security", 67),
            ("Pricing", 50)
        ],
        onHome: {},
        onRestart: {}
    )
}
