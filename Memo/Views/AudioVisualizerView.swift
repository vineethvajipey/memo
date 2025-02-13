import SwiftUI

struct AudioVisualizerView: View {
    let levels: [CGFloat]
    let active: Bool
    
    var body: some View {
        Canvas { context, size in
            let barWidth: CGFloat = 4.0
            let midY = size.height / 2
            let maxBars = Int(size.width / barWidth)
            let displayLevels = Array(levels.suffix(maxBars))
            
            for (index, level) in displayLevels.enumerated() {
                let normalizedLevel = min(level * size.height / 2, size.height / 2 - 2)
                let x = CGFloat(index) * barWidth
                
                // Draw upper bar
                let upperPath = Path { path in
                    path.move(to: CGPoint(x: x, y: midY))
                    path.addLine(to: CGPoint(x: x, y: midY - normalizedLevel))
                    path.addArc(
                        center: CGPoint(x: x + barWidth/2, y: midY - normalizedLevel),
                        radius: barWidth/2,
                        startAngle: .degrees(-180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                    path.addLine(to: CGPoint(x: x + barWidth, y: midY))
                }
                
                // Draw lower bar
                let lowerPath = Path { path in
                    path.move(to: CGPoint(x: x, y: midY))
                    path.addLine(to: CGPoint(x: x, y: midY + normalizedLevel))
                    path.addArc(
                        center: CGPoint(x: x + barWidth/2, y: midY + normalizedLevel),
                        radius: barWidth/2,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: true
                    )
                    path.addLine(to: CGPoint(x: x + barWidth, y: midY))
                }
                
                context.stroke(upperPath, with: .color(active ? .red : .gray))
                context.stroke(lowerPath, with: .color(active ? .red : .gray))
            }
        }
    }
}

#Preview {
    AudioVisualizerView(
        levels: Array(repeating: CGFloat.random(in: 0...1), count: 100),
        active: true
    )
    .frame(height: 60)
    .padding()
} 