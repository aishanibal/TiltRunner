import SwiftUI

struct HUDView: View {
    let score: Int
    let showPause: Bool
    let onPause: () -> Void

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
                if showPause {
                    Button(action: onPause) {
                        Image(systemName: "pause.fill")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.black.opacity(0.35), in: Circle())
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}
