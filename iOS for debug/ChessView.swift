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
                            .frame(width: Size.Point.squareSize_2DMode,
                                   height: Size.Point.squareSize_2DMode)
                    }
                }
            }
        }
        .overlay {
            ZStack {
                ForEach(self.model.sharedState.pieces.all) {
                    if let index = self.model.sharedState.pieces.indices[$0] {
                        PieceView(piece: $0, index: index)
                            .frame(width: Size.Point.squareSize_2DMode,
                                   height: Size.Point.squareSize_2DMode)
                    }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(white: 0.75), lineWidth: 3)
        }
        .gesture(
            DragGesture()
                .onChanged {
                    guard let piece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                        return
                    }
                    let dragTranslation = SIMD3<Float>(x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                                                       y: 0,
                                                       z: Size.Meter.convertFromPoint_2DMode($0.translation.height))
                    self.model.handle(.drag(piece,
                                            translation: dragTranslation))
                }
                .onEnded {
                    guard let piece = self.model.sharedState.pieces.piece_2DMode($0.startLocation) else {
                        return
                    }
                    let dragTranslation = SIMD3<Float>(x: Size.Meter.convertFromPoint_2DMode($0.translation.width),
                                                       y: 0,
                                                       z: Size.Meter.convertFromPoint_2DMode($0.translation.height))
                    self.model.handle(.drop(piece,
                                            dragTranslation: dragTranslation))
                }
        )
        .overlay {
            if self.model.showProgressView { ProgressView() }
        }
        .scaleEffect(self.model.sharedState.viewScale)
        .animation(.default, value: self.model.sharedState.viewScale)
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
                self.model.handle(.tapSquare(.init(self.row, self.column)))
            }
        }
        .onChange(of: self.model.sharedState.pieces) { self.updateInputtable() }
    }
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
    private func updateInputtable() {
        let myIndex = Index(self.row, self.column)
        if self.model.sharedState.pieces.isPicking {
            if !self.model.sharedState.pieces.indices.values.contains(myIndex) {
                self.inputtable = true
            } else {
                self.inputtable = (self.model.sharedState.pieces.pickingPieceIndex! == myIndex)
            }
        } else {
            self.inputtable = false
        }
    }
}

struct PieceView: View {
    @EnvironmentObject var model: AppModel
    var piece: Piece
    var index: Index
    var body: some View {
        ZStack {
            Color.clear
            Text(self.piece.chessmen.icon(isFilled: self.piece.side == .black))
                .font(.system(size: 60))
                .minimumScaleFactor(0.2)
        }
        .overlay(alignment: .topTrailing) {
            if self.model.sharedState.pieces.promotions[self.piece] == true {
                Circle().frame(width: 10, height: 10).padding(4)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            guard let entity = {
                self.model
                    .entities
                    .root
                    .children
                    .first { $0.components[Piece.self] == self.piece }?
                    .findEntity(named: "body")
            }() else { return }
            self.model.handle(.tapPiece(entity))
        }
        .border(.pink, width: self.model.sharedState.pieces.pickingPiece == self.piece ? 3 : 0)
        .offset(self.model.sharedState.pieces.offset_2DMode(self.piece, index))
        .animation(.default, value: self.model.sharedState.pieces.isDragging)
    }
}
