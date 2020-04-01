% Copyright 2018-2020 Harrison Pratt

interface tttGame
    open core

domains
    playerDOM = playerNone; playerX; playerO.
    playerListDOM = playerDOM*.
    cellDOM = cell(integer, integer, playerDOM).
    cellListDOM = cellDOM*.
    rcDOM = rc(integer, integer).
    rcListDOM = rcDOM*.

predicates
    playersInRow : (integer Row) -> playerListDOM Players.
    playersInDiag_DnToRt : (integer Row, integer Column) -> playerListDOM.
    playersInDiag_UpToRt : (integer Row, integer Column) -> playerListDOM.
    playersInColumn : (integer Col) -> playerListDOM Players.
    tryPlaceMarker : (integer Row, integer Col, playerDOM Player) determ.
    % fail if cell at R,C is occupied already
    couldWinTheseCells : (playerDOM Player, cellListDOM CellList) determ.
    % counts empty cells and cells occupied by Player, must be >= min. numberToWin
    playerHasWonAfterPlayingThisCell : (playerDOM Player, integer Row, integer Column) -> rcListDOM determ.
    % call this to see if specified player has won after placing a marker.

end interface tttGame
