/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           tttGame.cl
Project:        TicTacToeN
Package:        pack_GAME
Keywords:       
Created:        2020-03-29
Modified:       
Purpose:        Create the tttGame object containg the game board array used in playing the game
Comments:       
Examples:       
******************************************************************************/

class tttGame : tttGame
    open core

constants
    minBoardDimension : positive = 3.

constructors
    new : (positive BoardSize).

end class tttGame
