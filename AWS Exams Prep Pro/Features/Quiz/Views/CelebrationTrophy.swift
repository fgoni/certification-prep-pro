import SwiftUI

/// Trophy view displayed when user passes a quiz
struct CelebrationTrophy: View {
    var body: some View {
        ZStack {
            // Trophy base
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.yellow)
                .frame(width: 100, height: 20)
                .offset(y: 80)

            // Trophy stem
            Rectangle()
                .fill(Color.yellow)
                .frame(width: 20, height: 60)
                .offset(y: 20)

            // Trophy cup
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)

                // Star
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            }
            .offset(y: -30)

            // Sparkles
            ForEach(0..<4) { index in
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(x: 60, y: -60)
            }
        }
    }
}

#Preview {
    CelebrationTrophy()
}
