import SwiftUI

struct HistoricalResultsView: View {
    @State private var results: [QuizResult] = []
    @Environment(\.dismiss) private var dismiss

    private var averageScore: Int {
        guard !results.isEmpty else { return 0 }
        return Int((results.reduce(0) { $0 + $1.percentage } / Double(results.count)).rounded())
    }

    var body: some View {
        ZStack {
            AppTheme.V1.Colors.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if results.isEmpty {
                    emptyState
                } else {
                    trendCard
                        .padding(.horizontal, AppTheme.V1.Metrics.pad)
                        .padding(.bottom, 14)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(results) { result in
                                sessionRow(for: result)
                            }
                        }
                        .padding(.horizontal, AppTheme.V1.Metrics.pad)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            results = QuizResultsManager.shared.fetchResults().sorted { $0.date > $1.date }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            V1BackButton(title: "Home") { dismiss() }
                .padding(.bottom, 14)
            Text("History")
                .font(AppTheme.V1.Typography.displayLarge)
                .tracking(-0.4)
                .foregroundStyle(AppTheme.V1.Colors.ink)
            Text(results.isEmpty
                ? "No sessions yet"
                : "\(results.count) sessions · Avg \(averageScore)%")
                .font(AppTheme.V1.Typography.small)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.V1.Metrics.pad)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.V1.Colors.muted.opacity(0.6))
            Text("No quiz results yet")
                .font(AppTheme.V1.Typography.bodyEmphasis)
                .foregroundStyle(AppTheme.V1.Colors.ink)
            Text("Complete a quiz to start tracking your progress.")
                .font(AppTheme.V1.Typography.small)
                .foregroundStyle(AppTheme.V1.Colors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            V1Button(title: "Start a Quiz") { dismiss() }
                .padding(.horizontal, 60)
                .padding(.top, 12)
            Spacer()
        }
    }

    // MARK: - Trend chart
    private var trendCard: some View {
        V1Card {
            VStack(alignment: .leading, spacing: 0) {
                V1SectionLabel(text: "Score Trend")
                    .padding(.bottom, 10)
                trendChart
                    .frame(height: 60)
            }
        }
    }

    private var trendChart: some View {
        let points = results.prefix(8).reversed().map { $0.percentage }
        return GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = points.count
            let xs: [CGFloat] = count <= 1
                ? [w / 2]
                : (0..<count).map { CGFloat($0) * (w - 8) / CGFloat(count - 1) + 4 }
            let ys: [CGFloat] = points.map { h - CGFloat($0 / 100.0) * (h - 15) }

            ZStack {
                // 75% reference line
                Path { p in
                    let y = h - 0.75 * (h - 15)
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: w, y: y))
                }
                .stroke(AppTheme.V1.Colors.hair,
                        style: StrokeStyle(lineWidth: 1, dash: [2, 3]))

                // Trend polyline
                Path { p in
                    for (i, _) in points.enumerated() {
                        let pt = CGPoint(x: xs[i], y: ys[i])
                        if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                    }
                }
                .stroke(AppTheme.V1.Colors.accent,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // Dots
                ForEach(Array(points.enumerated()), id: \.offset) { i, val in
                    let passed = val >= 75
                    Circle()
                        .fill(passed ? AppTheme.V1.Colors.success : AppTheme.V1.Colors.danger)
                        .overlay(
                            Circle().stroke(AppTheme.V1.Colors.bg, lineWidth: 1.5)
                        )
                        .frame(width: 6, height: 6)
                        .position(x: xs[i], y: ys[i])
                }

                Text("75%")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(AppTheme.V1.Colors.muted)
                    .position(x: 12, y: h - 0.75 * (h - 15) - 6)
            }
        }
    }

    // MARK: - Session row
    private func sessionRow(for result: QuizResult) -> some View {
        let passed = result.percentage >= 75
        let pct = Int(result.percentage.rounded())
        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(passed ? AppTheme.V1.Colors.successSoft : AppTheme.V1.Colors.dangerSoft)
                Text("\(pct)")
                    .font(.system(size: 14, weight: .heavy))
                    .tracking(-0.5)
                    .monospacedDigit()
                    .foregroundStyle(passed ? AppTheme.V1.Colors.success : AppTheme.V1.Colors.danger)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(result.totalQuestions > 20 ? "Full" : "Quick") Quiz")
                    .font(AppTheme.V1.Typography.smallEmphasis)
                    .foregroundStyle(AppTheme.V1.Colors.ink)
                Text("\(formatDate(result.date)) · \(result.totalQuestions) Q · \(formatTime(result.timeSpent))")
                    .font(AppTheme.V1.Typography.caption)
                    .foregroundStyle(AppTheme.V1.Colors.muted)
            }
            Spacer()
            V1Chevron()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusSm)
                .fill(AppTheme.V1.Colors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.V1.Metrics.radiusSm)
                .stroke(AppTheme.V1.Colors.hair, lineWidth: 1)
        )
        .overlay(
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(passed ? AppTheme.V1.Colors.success : AppTheme.V1.Colors.danger)
                    .frame(width: 3)
                Spacer()
            }
            .padding(.vertical, 8)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let cal = Calendar.current
        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "HH:mm"
        let time = timeFmt.string(from: date)
        if cal.isDateInToday(date) { return "Today · \(time)" }
        if cal.isDateInYesterday(date) { return "Yesterday · \(time)" }
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "MMM d"
        return "\(dayFmt.string(from: date)) · \(time)"
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Preview
struct HistoricalResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoricalResultsView()
        }
        .environmentObject(ThemeManager())
    }
}
