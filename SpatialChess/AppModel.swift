import SwiftUI
import RealityKit
import GroupActivities
import Combine

class AppModel: ObservableObject {
    @Published var gameState: GameState = .init()
    var rootEntity: Entity = .init()
    
    @Published private(set) var groupSession: GroupSession<👤GroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
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
                let tappedPieceEntity = self.pieceEntity(id.uuidString)!
                let tappedPieceState = tappedPieceEntity.components[PieceStateComponent.self]!
                if self.gameState.previousSituation.contains(where: { $0.picked }) {
                    let pickedPieceEntity = self.pickedPieceEntity()!
                    if tappedPieceEntity == pickedPieceEntity {
                        tappedPieceEntity.move(to: .init(translation: tappedPieceState.index.position),
                                               relativeTo: self.rootEntity,
                                               duration: 1)
                        tappedPieceEntity.components[PieceStateComponent.self]!.picked = false
                    } else {
                        let pickedPieceState = pickedPieceEntity.components[PieceStateComponent.self]!
                        if tappedPieceState.side == pickedPieceState.side {
                            pickedPieceEntity.move(to: .init(translation: pickedPieceState.index.position),
                                                   relativeTo: self.rootEntity,
                                                   duration: 1)
                            pickedPieceEntity.components[PieceStateComponent.self]!.picked = false
                            var translation = tappedPieceState.index.position
                            translation.y = FixedValue.pickedOffset
                            tappedPieceEntity.move(to: .init(translation: translation),
                                                   relativeTo: self.rootEntity,
                                                   duration: 1)
                            tappedPieceEntity.components[PieceStateComponent.self]!.picked = true
                        } else {
                            tappedPieceEntity.components[PieceStateComponent.self]!.removed = true
                            pickedPieceEntity.move(to: .init(translation: tappedPieceState.index.position),
                                                   relativeTo: self.rootEntity,
                                                   duration: 1)
                            pickedPieceEntity.components[PieceStateComponent.self]!.index = tappedPieceState.index
                            pickedPieceEntity.components[PieceStateComponent.self]!.picked = false
                        }
                    }
                } else {
                    var translation = tappedPieceState.index.position
                    translation.y = FixedValue.pickedOffset
                    tappedPieceEntity.move(to: .init(translation: translation),
                                           relativeTo: self.rootEntity,
                                           duration: 1)
                    tappedPieceEntity.components[PieceStateComponent.self]!.picked = true
                }
            case .tapSquare(let index):
                guard let pickedPieceEntity = self.pickedPieceEntity() else { return }
                pickedPieceEntity.move(to: .init(translation: index.position),
                                       relativeTo: self.rootEntity,
                                       duration: 1)
                pickedPieceEntity.components[PieceStateComponent.self]?.index = index
                pickedPieceEntity.components[PieceStateComponent.self]?.picked = false
        }
    }
    func reloadPiecesPosition() {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .forEach {
                let pieceState = $0.components[PieceStateComponent.self]!
                $0.position = pieceState.index.position
                if pieceState.picked { $0.position.y = FixedValue.pickedOffset }
            }
    }
    func updateGameState(with action: Action) {
        self.gameState = .init(previousSituation: self.getLatestSituation(),
                               latestAction: action)
    }
    func getLatestSituation() -> [PieceStateComponent] {
        self.rootEntity
            .children
            .filter { $0.components.has(PieceStateComponent.self) }
            .reduce(into: []) {
                $0.append($1.components[PieceStateComponent.self]!)
            }
    }
}

//MARK: ==== SharePlay ====
extension AppModel {
    func sendMessage() {
        Task {
            try? await self.messenger?.send(self.gameState)
        }
    }
    private func receive(_ gameState: GameState) {
        self.gameState = gameState
        self.reloadPiecesPosition()
        if let action = gameState.latestAction {
            self.applyLatestAction(action)
        }
    }
}
