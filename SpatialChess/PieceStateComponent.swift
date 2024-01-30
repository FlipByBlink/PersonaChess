import RealityKit

struct PieceStateComponent: Component, Codable {
    var picked: Bool = false
    var index: Index
}
