import SwiftUI

struct AudioLevelView: View {
    let level: CGFloat // 0.0 to 1.0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index < Int(level * 20) ? Color.red : Color.gray.opacity(0.3))
                    .frame(width: 3, height: CGFloat(index + 1) * 2)
            }
        }
        .animation(.linear(duration: 0.1), value: level)
    }
}

#Preview {
    AudioLevelView(level: 0.7)
} 