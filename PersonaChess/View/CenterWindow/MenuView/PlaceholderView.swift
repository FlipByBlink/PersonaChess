import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        ZStack {
            Color.clear
            Image(systemName: "arrow.up")
                .font(.system(size: 100, weight: .bold))
                .foregroundStyle(.tertiary)
                .padding(48)
                .rotationEffect(.degrees(30))
        }
    }
}
