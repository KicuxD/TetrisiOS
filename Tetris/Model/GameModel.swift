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
    
    var timer: Timer?
    var speed: Double
    //initializer
    init(numRows: Int = 23, numColumns: Int = 10) {
        self.numRows = numRows
        self.numColumns = numColumns
        
        gameBoard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        speed = 0.1
        resumeGame()
    }
    
    func blockClicked(row: Int, column: Int) {
        print("Column: \(column), Row: \(row)")
        if gameBoard[column][row] == nil {
            gameBoard[column][row] = GameBlock(blockType: BlockType.allCases.randomElement()!)
        } else {
            gameBoard[column][row] = nil
        }
    }
    
    func resumeGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true, block: Engine)
    }
    
    func pauseGame() {
        timer?.invalidate()
    }
    //silnik do blokow
    func Engine(timer: Timer) {
        //stworzenie nowego bloku jesli jest taka potrzeba
        guard let currentTetrisElement = tetrisElement else {
            print("Tworzenie nowego bloku")
            tetrisElement = TetrisElement.createNewBlock(numRows: numRows, numColumns: numColumns)
            if !isElementValid(testTetrisElement: tetrisElement!) {
                print("Koniec gry!")
                pauseGame()
            }
            return
        }
        //zajecie sie blokiem idacym w dol
        let newTetrisElement = currentTetrisElement.moveBy(row: -1, column: 0)
        if isElementValid(testTetrisElement: newTetrisElement) {
        print("Przesuniecie bloku w dol")
        tetrisElement = newTetrisElement
        return
        }
        //sprawdzenie czy potrzebujemy postawic blok
        print("Postawienie bloku")
        placeTetrisElement()
    }
    
    func isElementValid(testTetrisElement: TetrisElement) -> Bool {
        for block in testTetrisElement.blocks {
            let row = testTetrisElement.origin.row + block.row
            if row < 0 || row >= numRows {return false}
            
            let column = testTetrisElement.origin.column + block.column
            if column < 0 || column >= numColumns {return false}
            
            if gameBoard[column][row] != nil {return false}
        }
        return true
    }
    
    func placeTetrisElement() {
        guard let currentTetrisElement = tetrisElement else {
            return
        }
        
        for block in currentTetrisElement.blocks {
            let row = currentTetrisElement.origin.row + block.row
            if row < 0 || row >= numRows {continue}
            
            let column = currentTetrisElement.origin.column + block.column
            if column < 0 || column >= numColumns {continue}
            
            gameBoard[column][row] = GameBlock(blockType: currentTetrisElement.blockType)
        }
        tetrisElement = nil
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
        return TetrisElement.getBlocks(blockType: blockType)
    }
    
    func moveBy(row: Int, column: Int) -> TetrisElement {
        let newOrigin = BlockLocation(row: origin.row + row, column: origin.column + column)
        return TetrisElement(origin: newOrigin, blockType: blockType)
    }
    
    static func getBlocks(blockType: BlockType) -> [BlockLocation] {
        switch blockType {
        case .i:
            return [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 2)]
        case .o:
        return [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: 1, column: 0)]
        case .t:
        return [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 0)]
        case .j:
        return [BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)]
        case .l:
        return [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1)]
        case .s:
        return [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: 1, column: 1)]
        case .z:
        return [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: -1, column: 1)]
        }
    }
    
    static func createNewBlock(numRows: Int, numColumns: Int) -> TetrisElement {
        let blockType = BlockType.allCases.randomElement()!
        
        var maxRow = 0
        for block in getBlocks(blockType: blockType) {
            maxRow = max(maxRow, block.row)
        }
        
        let origin = BlockLocation(row: numRows - 1 - maxRow, column: (numColumns-1)/2)
        return TetrisElement(origin: origin, blockType: blockType)
    }
}

struct BlockLocation {
    var row: Int
    var column: Int
}
