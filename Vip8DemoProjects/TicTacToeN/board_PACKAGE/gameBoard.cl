/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           gameBoard.cl
Project:        TicTacToeN
Package:        pack_BOARD
Keywords:       
Created:        2020-03-29
Modified:       
Purpose:        Create the resizable 'gameBoard' form used to play the TicTacToeN game.
                Handles drawing the grid, the 'X' and 'O' markers.
                Captures mouse-clicks to place markers or query possible winning moves.
Comments:       Inherits 'tttGame' to keep track of score and marker positions.
Examples:       
******************************************************************************/


class gameBoard : gameBoard
    open core

predicates
    display : (window Parent, positive NumCellsAcross) -> gameBoard GameBoard.

constructors
    new : (window Parent, positive NumCellsAcross).

end class gameBoard
