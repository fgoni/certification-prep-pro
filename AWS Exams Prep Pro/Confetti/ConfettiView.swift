import SwiftUI

struct ConfettiView: View {
    @State private var confetti: [Confetti] = []

    let colors: [Color] = [
        .red, .green, .blue, .yellow, .pink, .purple, .orange, .mint, .cyan
    ]

    var body: some View {
        ZStack {
            ForEach(confetti) { confetti in
                Circle()
                    .fill(confetti.color)
                    .frame(width: confetti.scale * 10, height: confetti.scale * 10)
                    .position(x: confetti.x, y: confetti.y)
                    .rotationEffect(.degrees(confetti.rotation))
                    .animation(
                        Animation.linear(duration: 2)
                            .repeatForever(autoreverses: false),
                        value: confetti.id
                    )
            }
        }
        .onAppear {
            withAnimation {
                generateConfetti()
            }
        }
    }

    func generateConfetti() {
        confetti = (0..<100).map { _ in
            Confetti(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5),
                color: colors.randomElement() ?? .blue
            )
        }

        // Animate the confetti
        for index in confetti.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...1)) {
                confetti[index].x += CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width)
                confetti[index].y += CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height)
            }
        }
    }
}
