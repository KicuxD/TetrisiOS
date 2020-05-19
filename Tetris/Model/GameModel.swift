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
        speed = 0.5
        resumeGame()
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
        // sprawdzenie czy mozna wyczyscic jakas linie
        
        if clearLine() {
            print("linia wyczyszczona")
            return
        }
        
        //stworzenie nowego bloku jesli jest taka potrzeba
        guard tetrisElement != nil else {
            print("Tworzenie nowego bloku")
            tetrisElement = TetrisElement.createNewBlock(numRows: numRows, numColumns: numColumns)
            if !isElementValid(testTetrisElement: tetrisElement!) {
                print("Koniec gry!")
                pauseGame()
            }
            return
        }
        
        //zajecie sie blokiem idacym w dol
        if moveElementDown() {
        print("Przesuniecie bloku w dol")
        return
        }
        
        //sprawdzenie czy potrzebujemy postawic blok
        print("Postawienie bloku")
        placeTetrisElement()
    }
    
    func dropElement() {
        while (moveElementDown()) { }
    }
    
    func moveElementRight() -> Bool {
        return moveElement(rowOffset: 0, columntOffset: 1)
    }
    
    func moveElementLeft() -> Bool {
        return moveElement(rowOffset: 0, columntOffset: -1)
    }
    
    func moveElementDown() -> Bool {
        return moveElement(rowOffset: -1, columntOffset: 0)
    }
    
    func moveElement (rowOffset: Int, columntOffset: Int) -> Bool {
        guard let currentTetrisElement = tetrisElement else {return false}
        
        let newTetrisElement = currentTetrisElement.moveBy(row: rowOffset, column: columntOffset)
        if isElementValid(testTetrisElement: newTetrisElement) {
        tetrisElement = newTetrisElement
        return true
        }
        return false
    }
    
    func rotateTetrisElement(clockwise: Bool) {
        guard let currentTetrisElement = tetrisElement else { return }
        
        let newTetrisElementBase = currentTetrisElement.rotate(clockwise: clockwise)
        let kicks = currentTetrisElement.getKicks(clockwise: clockwise)
        
        for kick in kicks {
            let newTetrisElement = newTetrisElementBase.moveBy(row: kick.row, column: kick.column)
            if isElementValid(testTetrisElement: newTetrisElement) {
                tetrisElement = newTetrisElement
                return
            }
        }
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
    
    func clearLine() -> Bool {
        var newBoard: [[GameBlock?]] = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        var boardUpdated = false
        var nextRowToCopy = 0
        
        for row in 0...numRows-1 {
            var clearLine = true
            for column in 0...numColumns-1 {
                clearLine = clearLine && gameBoard[column][row] != nil
            }
            if !clearLine {
                for column in 0...numColumns-1 {
                    newBoard[column][nextRowToCopy] = gameBoard[column][row]
                }
                nextRowToCopy += 1
            }
            boardUpdated = boardUpdated || clearLine
        }
        
        if boardUpdated {
            gameBoard = newBoard
        }
        return boardUpdated
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
    var rotation: Int
    
    var blocks: [BlockLocation] {
        return TetrisElement.getBlocks(blockType: blockType, rotation: rotation)
    }
    
    func moveBy(row: Int, column: Int) -> TetrisElement {
        let newOrigin = BlockLocation(row: origin.row + row, column: origin.column + column)
        return TetrisElement(origin: newOrigin, blockType: blockType, rotation: rotation)
    }
    
    func rotate(clockwise: Bool) -> TetrisElement {
        return TetrisElement(origin: origin, blockType: blockType, rotation: rotation + (clockwise ? 1 : -1))
    }
    
    func getKicks(clockwise: Bool) -> [BlockLocation] {
        return TetrisElement.getKicks(blockType: blockType, rotation: rotation, clockwise: clockwise)
    }

    
    static func getBlocks(blockType: BlockType, rotation: Int = 0) -> [BlockLocation] {
        let allBlocks = getAllBlocks(blockType: blockType)
        
        var index = rotation % allBlocks.count
        if (index < 0) { index += allBlocks.count}
        
        return allBlocks[index]
    }
    
    static func getAllBlocks(blockType: BlockType) -> [[BlockLocation]] {
        switch blockType {
        case .i:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 2)],
                    [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: -2, column: 1)],
                    [BlockLocation(row: -1, column: -1), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1), BlockLocation(row: -1, column: 2)],
                    [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: -2, column: 0)]]
        case .o:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: 1, column: 0)]]
        case .t:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 0)],
                    [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: -1, column: 0)]]
        case .j:
            return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: -1)]]
        case .l:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: -1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: 1, column: -1)]]
        case .s:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: -1)],
                    [BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0)]]
        case .z:
            return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: -1, column: -1)]]
        }
    }
    static func createNewBlock(numRows: Int, numColumns: Int) -> TetrisElement {
        let blockType = BlockType.allCases.randomElement()!
        
        var maxRow = 0
        for block in getBlocks(blockType: blockType) {
            maxRow = max(maxRow, block.row)
        }
        
        let origin = BlockLocation(row: numRows - 1 - maxRow, column: (numColumns-1)/2)
        return TetrisElement(origin: origin, blockType: blockType, rotation: 0)
    }
}
    static func getKicks(blockType: BlockType, rotation: Int, clockwise: Bool) -> [BlockLocation] {
        let rotationCount = getAllBlocks(blockType: blockType).count
        
        var index = rotation % rotationCount
        if index < 0 { index += rotationCount }
        
        var kicks = getAllKicks(blockType: blockType)[index]
        if !clockwise {
            var counterKicks: [BlockLocation] = []
            for kick in kicks {
                counterKicks.append(BlockLocation(row: -1 * kick.row, column: -1 * kick.column))
            }
            kicks = counterKicks
        }
        return kicks
    }

    static func getAllKicks(blockType: BlockType) -> [[BlockLocation]] {
    switch blockType {
        case .o:
            return [[BlockLocation(row: 0, column: 0)]]
        case .i:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -2), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: -2), BlockLocation(row: 2, column: -1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 2), BlockLocation(row: 2, column: -1), BlockLocation(row: -1, column: 2)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 2), BlockLocation(row: 0, column: -1), BlockLocation(row: 1, column: 2), BlockLocation(row: -2, column: -1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: -2), BlockLocation(row: -2, column: 1), BlockLocation(row: 1, column: -2)]
            ]
        case .j, .l, .s, .z, .t:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -2), BlockLocation(row: -2, column: -1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 1), BlockLocation(row: 2, column: 0), BlockLocation(row: 1, column: 2)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: -2, column: 0), BlockLocation(row: -2, column: 1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: -1, column: -1), BlockLocation(row: 2, column: 0), BlockLocation(row: 2, column: -1)]
            ]
        }
    }

struct BlockLocation {
    var row: Int
    var column: Int
}
