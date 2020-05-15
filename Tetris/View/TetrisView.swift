//
//  TetrisView.swift
//  Tetris iOS
//
//  Created by Dawid Zając & Maciej Fanok on 12/05/2020.
//  Copyright © 2020 Projekt. All rights reserved.
//

import SwiftUI

struct TetrisView: View {
    @ObservedObject var tetris = TetrisViewModel()
    
    var body: some View {
        GeometryReader {(geometry: GeometryProxy) in
            self.drawBoard(boundingRect: geometry.size)
        }
        .gesture(tetris.getGesture())
    }
    
    func drawBoard(boundingRect: CGSize) -> some View {
        let columns = self.tetris.numColumns
        let rows = self.tetris.numRows
        let blocksize = min(boundingRect.width/CGFloat(columns), boundingRect.height/CGFloat(rows))
        //padding
        let xoffset = (boundingRect.width - blocksize*CGFloat(columns))/2
        //vertical padding
        let yoffset = (boundingRect.height - blocksize*CGFloat(rows))/2
        let gameBoard = self.tetris.gameBoard
        
        return ForEach(0...columns-1, id:\.self) { (column:Int) in
            ForEach(0...rows-1, id:\.self) { (row:Int) in
                Path { path in
                    let x = xoffset + blocksize * CGFloat(column)
                    let y = boundingRect.height - yoffset - blocksize*CGFloat(row+1)
                    
                    let rect = CGRect(x: x, y: y, width: blocksize, height: blocksize)
                    path.addRect(rect)
                }
                .fill(gameBoard[column][row].color)
                .onTapGesture {
                    self.tetris.squareClicked(row: row, column: column)
                }
            }
        }
    }
}

struct TetrisView_Previews: PreviewProvider {
    static var previews: some View {
        TetrisView()
    }
}
