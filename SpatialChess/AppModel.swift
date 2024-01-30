import SwiftUI
import RealityKit
import GroupActivities
import Combine

class AppModel: ObservableObject {
    @Published var gameState: GameState = .init()
    var rootEntity: Entity = .init()
    
    @Published var groupSession: GroupSession<👤GroupActivity>?
    var messenger: GroupSessionMessenger?
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<Void, Never>>()
}

extension AppModel {
    func pieceEntity(_ name: String) -> Entity? {
        self.rootEntity.findEntity(named: name)
    }
    func pickedPieceEntity() -> Entity? {
        self.rootEntity.children.first { $0.components[PieceStateComponent.self]?.picked == true }
    }
    func applyLatestAction(_ action: Action) {
        switch action {
            case .tapPiece(let id):
                guard let entity = self.pieceEntity(id.uuidString) else {
                    assertionFailure()
                    return
                }
                let state = entity.components[PieceStateComponent.self]!
                var translation = state.index.position
                translation.y = state.picked ? 0 : 0.1
                entity.move(to: .init(translation: translation),
                            relativeTo: self.rootEntity,
                            duration: 1)
                entity.components[PieceStateComponent.self]!.picked.toggle()
            case .tapSquare(let index):
                guard let entity = self.pickedPieceEntity() else {
                    return
                }
                entity.move(to: .init(translation: index.position),
                            relativeTo: self.rootEntity,
                            duration: 1)
                entity.components[PieceStateComponent.self]?.index = index
                entity.components[PieceStateComponent.self]?.picked.toggle()
        }
        self.updateGameState(with: action)
        self.send()
    }
    func updatePosition() {
        self.rootEntity.children.forEach {
            if let pieceState = $0.components[PieceStateComponent.self] {
                $0.position = pieceState.index.position
                if pieceState.picked { $0.position.y += 0.1 }
            }
        }
    }
    func updateGameState(with action: Action) {
        self.gameState = .init(
            previousSituation: self.gameState.latestSituation,
            latestAction: action,
            latestSituation: {
                self.rootEntity
                    .children
                    .filter { $0.components.has(PieceStateComponent.self) }
                    .reduce(into: []) {
                        $0.append($1.components[PieceStateComponent.self]!)
                    }
            }()
        )
    }
}

//MARK: ==== SharePlay ====
extension AppModel {
    func send() {
        Task {
            try? await self.messenger?.send(self.gameState)
        }
    }
    func receive(_ gameState: GameState) {
        self.gameState.previousSituation = gameState.previousSituation
        self.updatePosition()
        if let action = gameState.latestAction {
            self.applyLatestAction(action)
        }
        self.gameState.latestSituation = gameState.latestSituation
    }
}
