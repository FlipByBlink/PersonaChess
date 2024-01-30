import RealityKit

struct PieceStateComponent: Component, Codable {
    var selected: Bool = false
    var index: Index
}
