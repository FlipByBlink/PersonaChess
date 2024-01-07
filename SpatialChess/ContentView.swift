import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        let index = column + row * 8
                        Color(white: (row + column) % 2 == 0 ? 0.2 : 0.7)
                            .hoverEffect(isEnabled: true)
                            .overlay {
                                if index == 28 {
                                    駒View()
                                }
                            }
                            .frame(width: チェスボードのサイズ.マスの一辺の大きさ,
                                   height: チェスボードのサイズ.マスの一辺の大きさ)
                    }
                }
            }
        }
        .overlay {
            ZStack {
                HStack(spacing: 0) {
                    ForEach(1...8, id: \.self) {
                        Spacer()
                        if $0 < 8 { Color.black.frame(width: 1) }
                    }
                }
                VStack(spacing: 0) {
                    ForEach(1...8, id: \.self) {
                        Spacer()
                        if $0 < 8 { Color.black.frame(height: 1) }
                    }
                }
            }
            .border(.black, width: 6)
        }
        .padding(チェスボードのサイズ.ボードの余白の大きさ)
        .background {
            Model3D(named: "シンプルボード") {
                $0
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.clear
            }
            .offset(z: -1)
        }
        .rotation3DEffect(.init(angle: .degrees(90), axis: .x))
        .offset(y: チェスボードのサイズ.ボードの高さオフセット)
        .frame(width: チェスボードのサイズ.ボードの一辺の大きさ,
               height: チェスボードのサイズ.ボードの一辺の大きさ)
        .frame(depth: チェスボードのサイズ.ボードの一辺の大きさ)
    }
}

enum チェスボードのサイズ {
    static let マスの一辺の大きさ: CGFloat = 150
    static var ボードの余白の大きさ: CGFloat = 48
    static var ボードの一辺の大きさ: CGFloat { Self.マスの一辺の大きさ * 8 + Self.ボードの余白の大きさ * 2 }
    static var ボードの高さオフセット: CGFloat { (Self.ボードの一辺の大きさ - 140) / 2 }
}

fileprivate
struct 駒View: View {
    @State private var opacity: Double = 0
    @State private var floating: Bool = false
    var body: some View {
        Model3D(named: "駒") {
            $0
                .scaleEffect(2.2, anchor: .back)
                .hoverEffect()
                .offset(z: self.floating ? チェスボードのサイズ.マスの一辺の大きさ * 1.5 : 0)
                .opacity(self.opacity)
                .task {
                    try? await Task.sleep(for: .seconds(0.1))
                    withAnimation(.default.speed(2)) { self.opacity = 1 }
                    try? await Task.sleep(for: .seconds(0.4))
                    withAnimation { self.floating = false }
                }
                .onTapGesture {
                    withAnimation { self.floating.toggle() }
                }
        } placeholder: {
            Color.clear
        }
    }
}
