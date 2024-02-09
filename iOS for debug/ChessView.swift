import SwiftUI
import RealityKit

struct ChessView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        SquareView(row, column)
                            .overlay { PieceView(row, column) }
                    }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(white: 0.75), lineWidth: 3)
        }
        .frame(width: 330, height: 330)
        .rotationEffect(.degrees(-self.model.activityState.boardAngle))
        .animation(.default, value: self.model.activityState.boardAngle)
        .task { self.model.setUpEntities() }
    }
}

struct SquareView: View {
    @EnvironmentObject var model: AppModel
    private var row: Int
    private var column: Int
    @State private var inputtable: Bool = false
    var body: some View {
        Group {
            if (self.column + self.row) % 2 == 1 {
                Rectangle()
                    .fill(.gray.secondary)
            } else {
                Color.clear
            }
        }
        .contentShape(.rect)
        .hoverEffect(isEnabled: self.inputtable)
        .onTapGesture {
            if self.inputtable {
                self.model.execute(.tapSquare(.init(self.row, self.column)))
            }
        }
        .onChange(of: self.model.activityState.chess) { self.updateInputtable() }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
    private func updateInputtable() {
        let latestActivePieces = self.model.activityState.chess.latest.filter { !$0.removed }
        if latestActivePieces.contains(where: { $0.picked }),
           !latestActivePieces.contains(where: { $0.index == .init(self.row, self.column) }) {
            self.inputtable = true
        } else {
            self.inputtable = false
        }
    }
}

struct PieceView: View {
    @EnvironmentObject var model: AppModel
    private var row: Int
    private var column: Int
    private var piece: Piece? {
        self.model.activityState.chess.latest.first {
            $0.index == .init(self.row, self.column)
            &&
            ($0.removed == false)
        }
    }
    var body: some View {
        if let piece {
            ZStack {
                Color.clear
                Text(piece.icon)
                    .font(.system(size: 60))
                    .minimumScaleFactor(0.2)
            }
            .contentShape(.rect)
            .onTapGesture {
                let entity = {
                    self.model
                        .rootEntity
                        .children
                        .first { ($0.components[Piece.self] as? Piece)?.id == piece.id }!
                        .findEntity(named: "body")
                }()!
                self.model.execute(.tapPiece(entity))
            }
            .border(.pink, width: piece.picked ? 3 : 0)
        }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

extension Piece {
    var icon: String {
        switch self.side {
            case .white:
                switch self.chessmen {
                    case .pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7: "♙"
                    case .rook0, .rook1: "♖"
                    case .knight0, .knight1: "♘"
                    case .bishop0, .bishop1: "♗"
                    case .queen: "♕"
                    case .king: "♔"
                }
            case .black:
                switch self.chessmen {
                    case .pawn0, .pawn1, .pawn2, .pawn3, .pawn4, .pawn5, .pawn6, .pawn7: "♟\u{FE0E}"
                    case .rook0, .rook1: "♜"
                    case .knight0, .knight1: "♞"
                    case .bishop0, .bishop1: "♝"
                    case .queen: "♛"
                    case .king: "♚"
                }
        }
    }
}
