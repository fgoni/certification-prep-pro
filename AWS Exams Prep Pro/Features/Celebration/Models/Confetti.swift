import SwiftUI

struct Confetti: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
    var color: Color
}
