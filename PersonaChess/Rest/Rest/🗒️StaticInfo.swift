import SwiftUI

enum 🗒️StaticInfo {
    static let appName: LocalizedStringResource = "PersonaChess"
    static var appSubTitle: LocalizedStringResource { "Apple Vision Pro" }
    
    static let appStoreProductURL: URL = .init(string: "https://apps.apple.com/app/id6482994319")!
    static var appStoreUserReviewURL: URL { .init(string: "\(Self.appStoreProductURL)?action=write-review")! }
    
    static var contactAddress: String { "softies.grazer_0y@icloud.com" }
    
    static let privacyPolicyDescription = """
        2024-04-22
        
        
        English
        
        This application doesn't collect user information.
        
        
        日本語(Japanese)
        
        このアプリ自身において、ユーザーの情報を一切収集しません。
        """
    
    static let webRepositoryURL: URL = .init(string: "https://github.com/FlipByBlink/PersonaChess")!
    static let webMirrorRepositoryURL: URL = .init(string: "https://gitlab.com/FlipByBlink/PersonaChess_Mirror")!

    static let versionInfos: [(version: String, date: String)] = [
        ("3.0", "2025-11-17"),
        ("2.0", "2025-07-04"),
        ("1.0", "2024-04-22"),
    ] //降順。先頭の方が新しい
    
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main,
             AppModel,
             SharedState,
             DragState,
             Window,
             ImmersiveSpace,
             ChessView,
             RealityKitScope,
             GuideMenu,
             SharePlay,
             Rest
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: [
                    "App.swift",
                ]
                case .AppModel: [
                    "AppModel.swift",
                    "handleInteraction.swift",
                    "executeAction.swift",
                    "sharePlay.swift",
                    "rest.swift",
                ]
                case .SharedState: [
                    "SharedState.swift",
                    "Pieces.swift",
                    "Piece.swift",
                    "Index.swift",
                    "Chessmen.swift",
                    "Side.swift",
                    "Action.swift",
                    "BoardPosition.swift",
                ]
                case .DragState: [
                    "DragState.swift",
                ]
                case .Window: [
                    "WindowView.swift",
                    "BottomButtons.swift",
                    "OpenAndDismissImmersiveSpaceButton.swift",
                    "RotateBoardButton.swift",
                    "RemoveButton.swift",
                    "UndoButton.swift",
                    "ResetButton.swift",
                    "OpenGuideMenuButton.swift",
                ]
                case .ImmersiveSpace: [
                    "ImmersiveSpaceView.swift",
                    "offset.swift",
                    "scaleAnchor.swift",
                ]
                case .ChessView: [
                    "ChessView.swift",
                    "BoardView.swift",
                    "SquareView.swift",
                    "BoardRotation.swift",
                    "MenuDuringImmersiveSpaceMode.swift",
                ]
                case .RealityKitScope: [
                    "Entities.swift",
                    "PieceEntity.swift",
                    "Sound.swift",
                ]
                case .GuideMenu: [
                    "GuideMenuView.swift",
                    "ShareChessButton.swift",
                    "SetUpMenu.swift",
                    "AboutOptionsMenuLink.swift",
                    "AboutAppLink.swift",
                    "WhatsSharePlayMenu.swift",
                    "WhatsPersonaMenu.swift",
                ]
                case .SharePlay: [
                    "AppGroupActivity.swift",
                    "SharePlayProvider.swift",
                    "GroupActivityRegistration.swift",
                ]
                case .Rest: [
                    "HandleGroupImmersion.swift",
                    "DebugView.swift",
                    "SceneKind.swift",
                    "Size.swift",
                    "Interaction.swift",
                    "PieceAnimation.swift",
                    "🗒️StaticInfo.swift",
                    "ℹ️AboutApp.swift",
                ]
            }
        }
    }
}
