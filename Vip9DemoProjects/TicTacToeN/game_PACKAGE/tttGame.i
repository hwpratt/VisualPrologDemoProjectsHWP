/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           tttGame.i
Project:        TicTacToeN
Package:        pack_GAME
Keywords:       
Created:        2020-03-29
Modified:       
Purpose:        These predicates communicate with the game board array in the tttGame object.
Comments:       
Examples:       
******************************************************************************/

interface tttGame
    open core

domains
    markerDOM = markerNone; markerX; markerO.
    markerListDOM = markerDOM*.
    rcDOM = rc(positive Row, positive Column).
    rcListDOM = rcDOM*.
    rcmDOM = rcm(positive Row, positive Column, markerDOM Marker).
    rcmListDOM = rcmDOM*.

predicates
    rowMarkers : (positive Row) -> markerListDOM Markers.
    colMarkers : (positive Column) -> markerListDOM Markers.
    diagMarkers_DnRt : (positive Row, positive Column) -> markerListDOM Markers. % \ diagonal
    diagMarkers_UpRt : (positive Row, positive Column) -> markerListDOM Markers. % / diagonal
    player : () -> markerDOM.
    playerStr : () -> string MarkerStr. % as 'X', 'O' or ' '
    playerWinner : () -> markerDOM determ.
    playerWinnerStr : () -> string determ.
    %
    tryGetWinningCells : (positive Row, positive Column) -> rcListDOM determ.
    tryPlaceMarker : (markerDom Marker, positive Row, positive Column) determ.
    countWaysToWin : (positive Row, positive Col) -> positive NumberOfWays. % for currPlayer
    %
    onBoard : (positive Row, positive Column) determ. % succeed ie Row & Column are valid for the board
    noMovesRemain : () determ. % succeed when no empty cells remain open to be played
    %
    emitBoard : (). % used for basic testing only while prototyping
    %
    rcmListAll : () -> rcmListDOM. % ALL cells
    rcmListUnoccupied : () -> rcmListDOM. % All Cells without an X or O marker
    rcmListOccupied : () -> rcmListDOM. % ALL OCCUPIED cells

end interface tttGame
