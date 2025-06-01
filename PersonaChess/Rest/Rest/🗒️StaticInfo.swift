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
        
        This application don't collect user infomation.
        
        
        日本語(Japanese)
        
        このアプリ自身において、ユーザーの情報を一切収集しません。
        """
    
    static let webRepositoryURL: URL = .init(string: "https://github.com/FlipByBlink/PersonaChess")!
    static let webMirrorRepositoryURL: URL = .init(string: "https://gitlab.com/FlipByBlink/PersonaChess_Mirror")!

    static let versionInfos: [(version: String, date: String)] = [("2.0", "2025-06-01"),
                                                                  ("1.0", "2024-04-22")] //降順。先頭の方が新しい
    
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main,
             SharedState,
             CenterWindow,
             ImmersiveSpace,
             ChessView,
             RealityKitScope,
             Size,
             SharePlay,
             Rest
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: [
                    "App.swift",
                    "AppModel.swift"
                ]
                case .SharedState: [
                    "SharedState.swift",
                    "Game.swift",
                    "Piece.swift",
                    "Index.swift",
                    "Chessmen.swift",
                    "Side.swift",
                    "Mode.swift",
                ]
                case .CenterWindow: [
                    "CenterWindowView.swift",
                    "SharePlayMenu.swift",
                ]
                case .ImmersiveSpace: [
                    "ImmersiveSpaceView.swift",
                    "ToolbarViewForFloorMode.swift",
                    "FloorModeDividers.swift",
                ]
                case .ChessView: [
                    "ChessView.swift",
                    "BoardView.swift",
                    "SquareView.swift",
                    "ToolbarsView.swift",
                    "ToolbarPosition.swift",
                    "ToolbarView.swift",
                ]
                case .RealityKitScope: [
                    "PieceEntity.swift",
                    "PieceOpacitySystem.swift",
                ]
                case .Size: [
                    "Size.swift",
                ]
                case .SharePlay: [
                    "AppGroupActivity.swift",
                    "SharePlayProvider.swift",
                ]
                case .Rest: [
                    "Action.swift",
                    "TargetScene.swift",
                    "Sound.swift",
                    "🗒️StaticInfo.swift",
                    "ℹ️AboutApp.swift",
                ]
            }
        }
    }
}
