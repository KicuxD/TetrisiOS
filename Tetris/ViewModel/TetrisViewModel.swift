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
    var lastMoveLocation : CGPoint?
    
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
    
    func getGesture() -> some Gesture {
        return DragGesture()
        .onChanged(onMoveChanged(value:))
        .onEnded(onMoveEnded(_:))
    }
    
    func onMoveChanged(value: DragGesture.Value) {
        guard let start = lastMoveLocation else {
            lastMoveLocation = value.location
            return
        }
        let xDiff = value.location.x - start.x
        if xDiff > 10 {
            print("Przesuniecie w prawo")
            let _ = gameModel.moveElementRight()
            lastMoveLocation = value.location
            return
        }
        
        if xDiff < -10 {
            print("Przesuniecie w lewo")
            let _ = gameModel.moveElementLeft()
            lastMoveLocation = value.location
            return
        }
        
        let yDiff = value.location.y - start.y
        if yDiff > 10 {
            print ("Przesuniecie w dol")
            let _ = gameModel.moveElementDown()
            lastMoveLocation = value.location
            return
        }
        
        if yDiff < -10 {
            print ("Rzut w dol")
            gameModel.dropElement()
            lastMoveLocation = value.location
            return
        }
    }
        
    func onMoveEnded(_: DragGesture.Value) {
        lastMoveLocation = nil
    }
        
}

struct TetrisSquare {
    var color: Color
}
