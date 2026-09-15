import SwiftUI

struct HUDView: View {
    let score: Int

    var body: some View {
        VStack {
            HStack {
                Text("\(score)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.35), in: Capsule())
                Spacer()
            }
            .padding()
            Spacer()
        }
    }
}
