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
            .offset(y: -100)
            .frame(height: Size.Point.board(self.physicalMetrics),
                   alignment: .bottom)
            .background { GuideMenuView() }
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    OpenAndDismiss3DSpaceButton()
                    Button {
                        self.model.rotateBoard()
                    } label: {
                        Label("Rotate", systemImage: "arrow.turn.right.up")
                    }
                    Button {
                        self.model.isMenuSheetShown.toggle()
                    } label: {
                        Label("Open menu", systemImage: "line.3.horizontal")
                    }
                    .opacity(self.model.isMenuSheetShown ? 0.7 : 1)
                }
            }
            .animation(.default, value: self.model.isMenuSheetShown)
            .volumeBaseplateVisibility(.hidden)
            .environment(\.sceneKind, .volume)
            .task { SharePlayProvider.registerGroupActivity() }
    }
}
