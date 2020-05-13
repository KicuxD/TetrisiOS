//
//  TetrisViewModel.swift
//  Tetris iOS
//
//  Created by Dawid on 12/05/2020.
//  Copyright © 2020 Projekt. All rights reserved.
//

import SwiftUI

class TetrisViewModel: ObservableObject {
    var numRows: Int
    var numColumns: Int
    @Published var gameBoard: [[TetrisSquare]]
    
    init(numRows: Int = 23, numColumns: Int = 10) {
        self.numRows = numRows
        self.numColumns = numColumns
        
        gameBoard = Array(repeating: Array(repeating: TetrisSquare(color: Color.black), count: numRows), count: numColumns)
    }
    
    func squareClicked(row: Int, column: Int) {
        print("Column: \(column), Row: \(row)")
        if gameBoard[column][row].color == Color.black {
            gameBoard[column][row].color = Color.red
        } else {
            gameBoard[column][row].color = Color.black
        }
    }
}

struct TetrisSquare {
    var color: Color
}
