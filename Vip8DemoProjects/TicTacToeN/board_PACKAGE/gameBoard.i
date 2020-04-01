/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           gameBoard.i
Project:        TicTacToeN
Package:        pack_BOARD
Keywords:       
Created:        2020-03-29
Modified:       
Purpose:        Access to gameBoard drawing properties.
                Access is only done within gameBoard.pro at this time.
Comments:       These could be handled with single facts in gameBoard.pro, 
                but are left accessible for future developement.
Examples:       
******************************************************************************/


interface gameBoard supports formWindow
    open core

properties
    cellBorderColor : ::color.
    cellColorBG : ::color.
    cellColorFG : ::color. % use only if use patterned fill; not currently implemented.
    cellInset : integer.
    cellsAcross : positive.
    cellsDown : positive.
    playerColorO : ::color.
    playerColorX : ::color.
    bDrawCellBorders : boolean.

end interface gameBoard
