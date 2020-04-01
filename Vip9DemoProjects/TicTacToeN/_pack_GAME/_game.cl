% Copyright 2018 Harrison Pratt

class game

    open core

domains
    cellDom = cell(positive Row, positive Column, positive OccupiedBy).
    cellListDom = cellDom*.

constants % a cell Owner may be ownerNil, but a cell Player is only ownerO or ownerX

    ownerNil = 0. % vacant cell
    ownerO = 1.
    ownerX = 2.

properties

    gameOver : boolean.
    % is initialized to FALSE when game starts;
    % is set to TRUE if a winner or can be no winner

predicates

    scanCellsTest : (positive Row, positive Column). % HWP 2019-11-25 new prototype code

    initializeWorld : (positive NumberOfRowsColums).

    placeMarker : (positive Row, positive Cell, positive Owner).
    ownerLetter : (positive IdNum) -> string XorOor_. % returns "_" if IdNum is not X or O
    ownerLetter : (positive Row, positive Col) -> string OwnerMarker. % owners include ownerNil
    switchPlayer : (positive OwnerID) -> positive OtherOwnerId. % call after each marker is placed

    getOccupiedCells : () -> cellListDom.
    getVacantCells : () -> cellListDom.

    isWinPossibleAny : (positive Row, positive Column) determ. % succeed if any Row, Col or Diag containing this cell is Owned
    tallyWinsPossible : (positive Row, positive Column, positive OwnerId) -> positive PossibleWinsForCellOwner.
    tallyWinsPossibleAll : (positive PlayerO [out], positive PlayerX [out]).
    tryGetWinner : () -> positive WinningOwner determ. % HWP 2019-11-28 make this local to class ???
    tryGetWinnerStr : () -> string WinnerStr determ.

end class game
