import SwiftUI

struct HistoricalResultsView: View {
    @State private var results: [QuizResult] = []
    @Environment(\.dismiss) private var dismiss  // Add this for navigation

    var body: some View {
        VStack(spacing: 20) {
            if results.isEmpty {
                Spacer()
                Text("Historical Quiz Results")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.all, 10)
                    .fixedSize(horizontal: false, vertical: true)
                            VStack(spacing: 20) {
                                Text("No tests taken yet. Go ahead and start one!")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("Return to Home")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            Spacer()
            } else {
                Spacer()
                Text("Historical Quiz Results")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.all, 10)
                    .fixedSize(horizontal: false, vertical: true)
                
                ScrollView {
                    LazyVStack(spacing: 16) {  // Changed to LazyVStack for better performance
                        ForEach(results) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date: \(result.date, formatter: dateFormatter)")
                                    .font(.headline)
                                Text("Score: \(result.score) / \(result.totalQuestions) (\(String(format: "%.1f", result.percentage))%)")
                                    .font(.subheadline)
                                Text("Time Spent: \(formatTime(result.timeSpent)) / \(formatTime(result.timeLimit))")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(result.percentage >= 70 ? Color.green.opacity(0.7) : Color.red.opacity(0.7))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .onAppear {
            results = QuizResultsManager.shared.fetchResults().sorted(by: { $0.date > $1.date })
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - PreviewProvider

struct HistoricalResultsView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalResultsView()
            .previewDevice("iPhone 14")
            .previewDisplayName("iPhone 14")
    }
}
