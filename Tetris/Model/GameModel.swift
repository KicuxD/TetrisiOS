//
//  GameModel.swift
//  Tetris
//
//  Created by Projekt on 13/05/2020.
//  Copyright © 2020 Dawid Zając & Maciej Fanok. All rights reserved.
//

import SwiftUI

class GameModel: ObservableObject {
    var numRows: Int
    var numColumns: Int
    @Published var gameBoard: [[GameBlock?]]
    @Published var tetrisElement: TetrisElement?
    
    init(numRows: Int = 23, numColumns: Int = 10) {
        self.numRows = numRows
        self.numColumns = numColumns
        
        gameBoard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        tetrisElement = TetrisElement(origin: BlockLocation(row: 22, column: 4), blockType: .i)
    }
    
    func blockClicked(row: Int, column: Int) {
        print("Column: \(column), Row: \(row)")
        if gameBoard[column][row] == nil {
            gameBoard[column][row] = GameBlock(blockType: BlockType.allCases.randomElement()!)
        } else {
            gameBoard[column][row] = nil
        }
    }
}

struct GameBlock {
    var blockType: BlockType
    
}

enum BlockType: CaseIterable {
    case i, t, o, j, l, s, z
}

struct TetrisElement {
    var origin: BlockLocation
    var blockType: BlockType
    
    var blocks: [BlockLocation] {
        [
            BlockLocation(row: 0, column: -1),
            BlockLocation(row: 0, column: 0),
            BlockLocation(row: 0, column: 1),
            BlockLocation(row: 0, column: 2),
        ]
    }
    
}

struct BlockLocation {
    var row: Int
    var column: Int
}
