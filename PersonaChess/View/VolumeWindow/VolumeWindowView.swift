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
                        self.model.execute(.undo)
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .disabled(self.model.sharedState.logs.isEmpty)
                    .disabled(self.model.isAnimating)
                    Button {
                        self.model.execute(.reset)
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .disabled(self.model.sharedState.pieces.isPreset)
                    .disabled(self.model.isAnimating)
                    Button {
                        self.model.isGuideMenuShown.toggle()
                    } label: {
                        Label("Open menu", systemImage: "line.3.horizontal")
                    }
                    .opacity(self.model.isGuideMenuShown ? 0.7 : 1)
                    .disabled(self.model.groupSession != nil)
                }
            }
            .animation(.default, value: self.model.isGuideMenuShown)
            .volumeBaseplateVisibility(.hidden)
            .environment(\.sceneKind, .volume)
            .task { SharePlayProvider.registerGroupActivity() }
    }
}
