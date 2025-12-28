import SwiftUI

struct HistoricalResultsView: View {
    @State private var results: [QuizResult] = []
    @Environment(\.dismiss) private var dismiss
    
    private var averageScore: Double {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0) { $0 + $1.percentage } / Double(results.count)
    }
    
    private var passRate: Double {
        guard !results.isEmpty else { return 0 }
        let passedCount = results.filter { $0.percentage >= 70 }.count
        return Double(passedCount) / Double(results.count) * 100
    }
    
    private var averageTimeSpent: Double {
        guard !results.isEmpty else { return 0 }
        return Double(results.reduce(0) { $0 + $1.timeSpent }) / Double(results.count)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if results.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Quiz Results Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Complete a quiz to see your results and track your progress.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Start a Quiz")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                Spacer()
            } else {
                // Statistics Overview
                VStack(alignment: .center, spacing: 16) {
                    Text("Overview")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    HStack(spacing: 24) {
                        VStack(alignment: .center, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Average Score")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text(String(format: "%.1f%%", averageScore))
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .center, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Pass Rate")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text(String(format: "%.1f%%", passRate))
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .center, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                Text("Avg. Time")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text(formatTime(Int(averageTimeSpent)))
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Results List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(results) { result in
                            ResultCard(result: result)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            results = QuizResultsManager.shared.fetchResults().sorted { $0.date > $1.date }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Result Card View
struct ResultCard: View {
    let result: QuizResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(result.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(result.date, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(result.score)/\(result.totalQuestions)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Percentage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", result.percentage))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(result.percentage >= 70 ? .green : .red)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatTime(result.timeSpent))
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Time Limit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatTime(result.timeLimit))
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - PreviewProvider
struct HistoricalResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoricalResultsView()
        }
        .previewDevice("iPhone 14")
        .previewDisplayName("iPhone 14")
    }
}
