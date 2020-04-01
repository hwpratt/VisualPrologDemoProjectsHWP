/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           askGameSize.cl
Project:        TicTacToeN
Package:        pack_GAME
Keywords:       
Created:        2020-03-29
Modified:       
Purpose:        Ask the user for an integral game size.
                Size is the X & Y dimension, and must be >= 3.
Comments:       FAILS on [Cancel] pressed.
Examples:       
******************************************************************************/


class askGameSize : askGameSize
    open core

predicates
    display : (window Parent) -> integer GameSize determ.

constructors
    new : (window Parent).

end class askGameSize
