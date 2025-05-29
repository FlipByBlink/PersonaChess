//
//  VolumeWindowView.swift
//  2025/05/18
//

import SwiftUI

struct VolumeWindowView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    
    var body: some View {
        ChessView()
            .frame(height: Size.Point.board(self.physicalMetrics),
                   alignment: .bottom)
            .background {
                Rectangle()
                    .stroke(.pink, lineWidth: 14)
            }
            .background {
                GuideMenuView()
                    .opacity(self.model.isMenuSheetShown ? 1 : 0)
            }
            .overlay {
                GeometryReader {
                    Text("\($0.size.width), \($0.size.height)")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(radius: 6)
                }
            }
            .ornament(attachmentAnchor: .scene(.topBack)) {
                if !self.model.isMenuSheetShown {
                    Button {
                        self.model.isMenuSheetShown = true
                    } label: {
                        Label("Open menu", systemImage: "line.3.horizontal")
                    }
                    .buttonStyle(.borderless)
                    .glassBackgroundEffect()
                }
            }
            .animation(.default, value: self.model.isMenuSheetShown)
            .volumeBaseplateVisibility(.hidden)
            .task { SharePlayProvider.registerGroupActivity() }
    }
}
