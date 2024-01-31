import Foundation

enum FixedValue {
    static let squareSize: Float = 0.07
    
    static var boardSize: CGFloat { .init(Self.squareSize * 8) }
    
    static let pickedOffset: Float = 0.1
    
    static var preset: [PieceStateComponent] {
        var value: [PieceStateComponent] = []
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1].enumerated().forEach {
            value.append(.init(index: .init(0, $0.offset),
                               chessmen: $0.element,
                               side: .black))
        }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7].enumerated().forEach {
            value.append(.init(index: .init(1, $0),
                               chessmen: $1,
                               side: .black))
        }
        [Chessmen.pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7].enumerated().forEach {
            value.append(.init(index: .init(6, $0),
                               chessmen: $1,
                               side: .white))
        }
        [Chessmen.rook0, .knight0, .bishop0, .queen, .king, .bishop1, .knight1, .rook1].enumerated().forEach {
            value.append(.init(index: .init(7, $0.offset),
                               chessmen: $0.element,
                               side: .white))
        }
        return value
    }
}
