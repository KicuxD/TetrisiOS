//
//  TetrisViewModel.swift
//  Tetris iOS
//
//  Created by Dawid on 12/05/2020.
//  Copyright © 2020 Projekt. All rights reserved.
//

import SwiftUI
import Combine

class TetrisViewModel: ObservableObject {
    @Published var gameModel = GameModel()
    
    var numRows: Int {gameModel.numRows}
    var numColumns: Int {gameModel.numColumns}
    var gameBoard: [[TetrisSquare]] {
        var board = gameModel.gameBoard.map { $0.map(convertToSquare) }
        
        if let tetrisElement = gameModel.tetrisElement {
            for blockLocation in tetrisElement.blocks {
                board[blockLocation.column + tetrisElement.origin.column][blockLocation.row + tetrisElement.origin.row] = TetrisSquare(color: getColor(blockType: tetrisElement.blockType))
            }
        }
        return board
    }
    
    var anyCancellable : AnyCancellable?
    
    init() {
        anyCancellable = gameModel.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }

    func convertToSquare(block: GameBlock?) -> TetrisSquare {
        return TetrisSquare (color: getColor(blockType: block?.blockType))
    }
    
    func getColor (blockType: BlockType?) -> Color {
        switch blockType {
        case .i:
            return .blue
        case .j:
            return .purple
        case .l:
            return .orange
        case .o:
            return .red
        case .s:
            return .green
        case .t:
            return .yellow
        case .z:
            return .gray
        case .none:
            return .black
        }
    }
    
    func squareClicked(row: Int, column: Int) {
        gameModel.blockClicked(row: row, column: column)
    }
}

struct TetrisSquare {
    var color: Color
}
