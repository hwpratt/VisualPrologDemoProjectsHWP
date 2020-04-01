% Copyright 2018-2019 Harrison Pratt

implement game
    open core, list, std, exception, string, stdio
    open replicantList

/* SYNTAX NOTES

    Owner:  enumerable, 0..2; may be a Nil owner
    Owned:  a row, column or diagonal contains 1+ of a player, but not the other
    Player: O or X; Nil is NOT a Player
    Occupied: one or more Players is present in a cell; opposite of Vacant
    Vacant: not occupied by any Player, all Nil ownwers

*/
domains
    diagonalDomList = diagonalDom*.
    diagonalDom = diagLTRB; diagRTLB. % orientation of diagonal marker row

class facts - gameLayoutDB % asserted on initialization, never changed
    worldDim : positive := erroneous. % RowsAndColumnsNum
    cellList : cellListDom := erroneous.
    cellIndexList : positive_list := erroneous. % [1,2,...worldDim]

class facts - propertyDB
    gameOver_fact : boolean := erroneous.

clauses % for properties
    gameOver() = gameOver_fact.  % getter
    gameOver(BOOLEAN) :-
        gameOver_fact := BOOLEAN.  % setter

/******************************************************************************

-----------------------------------------------------------------------------*/
%class predicates
%    initializeWorld : (positive NumberOfRowsColums).
clauses
    initializeWorld(BoardSize) :-
        gameOver := false,
        worldDim := BoardSize,
        setNumInRowToWinByGameSize(BoardSize),
        cellIndexList := genPosList(1, worldDim),
        cellList :=
            [ Cell ||
                R = fromTo(1, BoardSize),
                C = fromTo(1, BoardSize),
                Cell = cell(R, C, ownerNil)
            ].

/******************************************************************************

-----------------------------------------------------------------------------*/
%class predicates
%    placeMarker : (positive Row, positive Cell, positive Owner).
clauses
    placeMarker(R, C, Owner) :-
        if VacantCell = tryGetCell(R, C, ownerNil) then
            cellList := [cell(R, C, Owner) | list::remove(cellList, VacantCell)]
        else
            vpiCommonDialogs::error(predicate_fullname(), string::format("\nCell at %,% is occupied.  Cannot place another marker here.", R, C))
        end if.

/*---------------------------------------------------------------------------*/
class predicates
    getCell : (positive Row, positive Column) -> cellDom. % don't care about owner
clauses
    getCell(R, C) = cell(R, C, Owner) :-
        if cell(R, C, Owner) in cellList and ! then
        else
            raise_user(string::format("Failed to get cell(%,%,_)", R, C))
        end if.

class predicates
    tryGetCell : (positive Row, positive Column, positive Owner) -> cellDom determ. % get cell with specific owner
clauses
    tryGetCell(R, C, Owner) = cell(R, C, Owner) :-
        cell(R, C, Owner) in cellList,
        !.

class predicates
    getCellOwner : (positive Row, positive Column) -> positive Owner.
clauses
    getCellOwner(R, C) = Owner :-
        if cell(R, C, Owner) in cellList then
        else
            raise_user(string::format("No cell found for Row = % and Column = %", R, C))
        end if.

%class predicates
%    ownerLetter : (positive Row, positive Col) -> string OwnerMarker.
clauses
    ownerLetter(R, C) = Letter :-
        Letter = ownerLetter(getCellOwner(R, C)).

% predicates
%   ownerLetter : (positive IdNum) -> string XorO.
clauses
    ownerLetter(IdNum) = LetterStr :-
        ownerLetterLookup(IdNum, LetterStr),
        !
        or
        exception::raise_errorf("IdNum = '%' is not defined in ownerLetter/2 for use in %", IdNum, predicate_fullname()).

class predicates
    ownerLetterLookup : (positive, string [out]) determ.
clauses
    ownerLetterLookup(ownerNil, "_").
    ownerLetterLookup(ownerO, "O").
    ownerLetterLookup(ownerX, "X").

/******************************************************************************
    TEST THE GAME BOARD
******************************************************************************/
class predicates
    getCellDagonalIdList : (positive Row, positive Column) -> diagonalDomList. % [idagLTRB and/or/none diag RTLB]
clauses
    getCellDagonalIdList(R, C) = DiagonalList :-
        if tuple(R, C) in getDiagonalRowColTuples(diagLTRB) then
            D1 = [diagLTRB]
        else
            D1 = []
        end if,
        if tuple(R, C) in getDiagonalRowColTuples(diagRTLB) then
            D2 = [diagRTLB]
        else
            D2 = []
        end if,
        DiagonalList = list::append(D1, D2).

class predicates
    getDiagonalRowColTuples : (diagonalDom) -> tuple{positive Row, positive Column}*.
clauses
    getDiagonalRowColTuples(DiagDom) = TupleList :-
        if DiagDom = diagLTRB then
            TupleList = list::zip(cellIndexList, cellIndexList)
        elseif DiagDom = diagRTLB then
            TupleList = list::zip(cellIndexList, reverse(cellIndexList))
        else
            exception::raise_user("Should never get here")
        end if.

class predicates
    isOccupiedColumn : (positive Column) determ.
clauses
    isOccupiedColumn(C) :-
        cell(_, C, Owner) in cellList,
        Owner <> ownerNil,
        !.

class predicates
    isOccupiedRow : (positive Row) determ.
clauses
    isOccupiedRow(R) :-
        cell(R, _, Owner) in cellList,
        Owner <> ownerNil,
        !.

class predicates
    isOccupiedDiagonal : (diagonalDOM) determ.
clauses
    isOccupiedDiagonal(DiagDOM) :-
        tuple(R, C) in getDiagonalRowColTuples(DiagDOM),
        ownerNil <> getCellOwner(R, C),
        !.

%----- a row, column or diagonal is "Owned" if it contains ONLY one type of Owner
%----- it may be PARTIALLY occupied, complete occupancy is not required
class predicates
    isRowOwnedBy : (positive Row, positive Owner) determ.
clauses
    isRowOwnedBy(R, O) :-
        [O] = getRowPlayersU(R).

class predicates
    isColumnOwnedBy : (positive Column, positive Owner) determ.
clauses
    isColumnOwnedBy(C, O) :-
        [O] = getColumnPlayersU(C).

class predicates
    isDiagonalOwnedBy : (diagonalDom, positive Ownwer) determ.
clauses
    isDiagonalOwnedBy(diagLTRB, Owner) :-
        [Owner] = getDiagonalPlayersU(diagLTRB).

/******************************************************************************

******************************************************************************/
class predicates
    getGameCellsSorted : () -> cellListDom GameCellsInLogicalOrder.
clauses
    getGameCellsSorted() = list::sort(cellList).

class predicates
    getRowCellsSorted : (positive Row) -> cellListDom RowCells.
clauses
    getRowCellsSorted(R) = list::sort([ cell(R, Col, Occ) || cell(R, Col, Occ) in cellList ]).

class predicates
    getColCellsSorted : (positive Col) -> cellListDom ColumnCells.
clauses
    getColCellsSorted(C) = list::sort([ cell(Row, C, Occ) || cell(Row, C, Occ) in cellList ]).

class predicates
    getRowOccupancyList : (positive Row) -> positive_list OccupancyList.
clauses
    getRowOccupancyList(R) = [ O || cell(R, _C, O) in getRowCellsSorted(R) ].

class predicates
    getColOccupancyList : (positive Col) -> positive_list OccupancyList.
clauses
    getColOccupancyList(C) = [ O || cell(_R, C, O) in getColCellsSorted(C) ].

/*---------------------------------------------------------------------------*/
% class predicates
%    getOccupiedCells : () -> cellListDom.
clauses
    getOccupiedCells() = OccupiedCells :-
        OccupiedCells =
            [ cell(R, C, O) ||
                cell(R, C, O) in cellList,
                O <> ownerNil
            ].

class predicates
    getRowPlayers : (positive Row) -> positive_list.
clauses
    getRowPlayers(R) = OO :-
        OO =
            [ O ||
                cell(R, _, O) in cellList,
                O <> ownerNil
            ].

class predicates
    getColumnPlayers : (positive Column) -> positive_list Players.
clauses
    getColumnPlayers(C) = OO :-
        OO =
            [ O ||
                cell(_, C, O) in cellList,
                O <> ownerNil
            ].

class predicates
    getDiagonalPlayers : (diagonalDom) -> positive_list. % Player is an owner who is NOT ownerNil
clauses
    getDiagonalPlayers(DiagDOM) = PP :-
        CellList = getDiagonalCells(DiagDOM),
        PP =
            [ P ||
                cell(_R, _C, P) in CellList,
                P <> ownerNil
            ].

class predicates
    getDiagonalOccupancyList : (diagonalDom) -> positive_list.
clauses
    getDiagonalOccupancyList(DiagDOM) = OO :-
        CellList = getDiagonalCells(DiagDOM),
        OO = [ O || cell(_R, _C, O) in CellList ].

/*-  UNIQUE PLAYERS tell you which players occupy a row, diagonal or column  */
class predicates
    getRowPlayersU : (positive Row) -> positive_list Players.
    % return unique X or O Players : [], [X,O], [X], [O]
clauses
    getRowPlayersU(R) = OO :-
        OO = removeDuplicates(getRowPlayers(R)).

class predicates
    getColumnPlayersU : (positive Column) -> positive_list.
    % return unique X or O Players : [], [X,O], [X], [O]
clauses
    getColumnPlayersU(C) = OO :-
        OO = removeDuplicates(getColumnPlayers(C)).

class predicates
    getDiagonalPlayersU : (diagonalDom) -> positive_list.
clauses
    getDiagonalPlayersU(DiagDom) = OO :-
        OO = removeDuplicates(getDiagonalPlayers(DiagDom)).

/*---------------------------------------------------------------------------*/
class predicates
    getDiagonalCells : (diagonalDom) -> cellListDom. % list of all cells in specified diagonal
clauses
    getDiagonalCells(DiagDom) = CC :-
        CC =
            [ Cell ||
                tuple(R, C) in getDiagonalRowColTuples(DiagDom),
                Cell = getCell(R, C)
            ].

class predicates
    getVacantDiagonalIds : () -> diagonalDomList DiagonalIdList.
clauses
    getVacantDiagonalIds() = DD :-
        if getDiagonalPlayers(diagLTRB) = [] then
            L1 = [diagLTRB]
        else
            L1 = []
        end if,
        if getDiagonalPlayers(diagRTLB) = [] then
            L2 = [diagRTLB]
        else
            L2 = []
        end if,
        DD = append(L1, L2).

class predicates
    getVacantRowNums : () -> positive_list.
clauses
    getVacantRowNums() = RR :-
        RR =
            [ R ||
                R in cellIndexList,
                not(isOccupiedRow(R))
            ].

class predicates
    getVacantColumnNums : () -> positive_list.
clauses
    getVacantColumnNums() = CC :-
        CC =
            [ C ||
                C in cellIndexList,
                not(isOccupiedColumn(C))
            ].

%class predicates
%    getVacantCells : () -> cellListDom.
clauses
    getVacantCells() = VacantCells :-
        VacantCells =
            [ cell(R, C, O) ||
                cell(R, C, O) in cellList,
                O = ownerNil
            ].

class predicates
    isVacantCell : (positive Row, positive Column) determ.
clauses
    isVacantCell(R, C) :-
        cell(R, C, ownerNil) in cellList,
        !.

class predicates
    isVacantRow : (positive Row) determ.
clauses
    isVacantRow(R) :-
        C in cellIndexList,
        cell(R, C, O) in cellList,
        O = ownerNil,
        !.

class predicates
    isVacantColumn : (positive Column) determ.
clauses
    isVacantColumn(C) :-
        R in cellIndexList,
        cell(R, C, O) in cellList,
        O = ownerNil,
        !.

class predicates
    isVacantDiagonal : (diagonalDom) determ.
clauses
    isVacantDiagonal(DiagDOM) :-
        tuple(R, C) in getDiagonalRowColTuples(DiagDOM),
        ownerNil <> getCellOwner(R, C),
        !,
        fail.
    isVacantDiagonal(_).

%----- NEW STUFF BELOW -----
class predicates
    canWinRow : (positive Row, positive Player) determ.
clauses
    canWinRow(R, P) :-
        CC =
            [ C ||
                cell(R, C, U) in cellList,
                list::isMember(U, [ownerNil, P])
            ],
        list::length(CC) >= numInRowToWin.

class predicates
    canWinRowPlayers : (positive Row) -> positive_list PlayerList.
    % returns [], [ownerO,ownerX], [ownerX],  or [ownerO].
    % but does not look for replicates, so might need more refinement.
clauses
    canWinRowPlayers(R) = CanWin:value :-
        CanWin = varM::new([]),
        if canWinRow(R, ownerO) then
            CanWin:value := [ownerO | CanWin:value]
        end if,
        if canWinRow(R, ownerX) then
            CanWin:value := [ownerX | CanWin:value]
        end if.

%        CC = getRowCellsSorted(R),
%        NumX = varM_integer::new(0),
%        NumO = varM_integer::new(0),
%        foreach cell(_, _, O) in CC do
%            if O = ownerNil then
%                NumO:inc(),
%                NumX:inc()
%            elseif O = ownerX then
%                NumX:inc()
%            else
%                NumO:inc()
%            end if
%        end foreach,
%        PossibleWinners = varM::new([ownerO, ownerX]),
%        if NumO:value < numInRowToWin then
%            PossibleWinners:value := list::remove(PossibleWinners:value, ownerO)
%        end if,
%        if NumX:value < numInRowToWin then
%            PossibleWinners:value := list::remove(PossibleWinners:value, ownerX)
%        end if.
/******************************************************************************
                CALCULATE WINNING (POSSIBLY) MOVES

                    BoardSize       # to Win
                        3               3
                        5               4
                        7               6
                        8+              ceiling(N/2) + 1
                        9               6
                        15              9
******************************************************************************/
class facts
    numInRowToWin : positive := 0.

class predicates
    setNumInRowToWinByGameSize : (positive NumCellsAcross).
clauses
    setNumInRowToWinByGameSize(N) :-
        if N = 3 then
            numInRowToWin := 3
        elseif N = 5 or N = 7 then
            numInRowToWin := N - 1
        elseif N < 7 then
            exception::raise_user(format("Number of cells across must be 3, 5,or 7.  You entered %", N))
        else
            numInRowToWin := math::ceil(N div 2) + 1,
            vpiCommonDialogs::note("New game", string::format("You need % in a row to win.", numInRowToWin))
%            numInRowToWin := 5 % HWP 2019-11-28 tweak to adjust winning # rule
        end if.

%class predicates
%    tryGetWinnerStr : () -> string WinnerStr determ.
%clauses
    tryGetWinnerStr() = WinnerStr :-
        WinnerStr = ownerLetter(tryGetWinner()).

%class predicates
%    tryGetWinner : () -> positive WinningOwner determ.
%clauses
    tryGetWinner() = WinningOwner :-
        Row in cellIndexList,
        WinningOwner = tryGetRowWin(Row),
        !.
    tryGetWinner() = WinningOwner :-
        Col in cellIndexList,
        WinningOwner = tryGetColWin(Col),
        !.
    tryGetWinner() = WinningOwner :-
        D in [diagLTRB, diagRTLB],
        tuple(D, WinningOwner) = tryGetDiagWin(D),
        !.

class predicates
    tryGetRowWin : (positive Row) -> positive Owner determ.
clauses
    tryGetRowWin(R) = O :-
        OO = getRowOccupancyList(R),
        playerCount(OO) >= 2,
        tuple(O, _Num) = getReplicantCountMin(OO, numInRowToWin),
        O <> ownerNil,
        stdio::writef("\nWinner is % in Row %", O, R).

class predicates
    tryGetColWin : (positive Column) -> positive Owner determ.
clauses
    tryGetColWin(C) = O :-
        OO = getColOccupancyList(C),
        playerCount(OO) >= 2,
        tuple(O, _Num) = getReplicantCountMin(OO, numInRowToWin),
        O <> ownerNil,
        stdio::writef("\nWinner is % in Column %", O, C).

class predicates
    tryGetDiagWin : (diagonalDom) -> tuple{diagonalDom Diag, positive Owner} determ.
clauses
    tryGetDiagWin(DiagDom) = tuple(DiagDom, O) :-
        OO = getDiagonalOccupancyList(DiagDom),
        playerCount(OO) >= 2,
        tuple(O, _Num) = getReplicantCountMin(OO, numInRowToWin),
        O <> ownerNil,
        stdio::writef("\nWinner is % in Diagonal %", O, toString(DiagDom)).

class predicates
    playerCount : (positive_list Owners) -> positive PlayerCount. % count of non-ownerNil owners, i.e. Players
clauses
    playerCount(OO) = N:value :-
        N = varM_integer::new(0),
        foreach O in OO do
            if O <> ownerNil then
                N:inc()
            end if
        end foreach.

/*---------------------------------------------------------------------------*/
%class predicates
%    tallyWinsPossible : (positive Row, positive Column, positive OwnerId) -> positive PossibleWinsForCellOwner.
clauses
    tallyWinsPossible(Row, Column, OwnerId) = N:value :-
        N = varM_integer::new(0),
        Opponent = switchPlayer(OwnerId),
        if not(isMember(Opponent, getRowPlayersU(Row))) then
            N:inc()
        end if,
        if not(isMember(Opponent, getColumnPlayersU(Column))) then
            N:inc()
        end if,
        Diagonals = getCellDagonalIdList(Row, Column), % empty if cell(R,C,_) is not on a diagonal
        foreach Diag in Diagonals do
            OO = getDiagonalPlayersU(Diag),
            if not(isMember(Opponent, OO)) then
                N:inc()
            end if
        end foreach.

/*---------------------------------------------------------------------------*/
%class predicates
%    scanCellsTest : (positive Row, positive Column).
%clauses
    scanCellsTest(Row, Column) :-
        % HWP 2019-11-25 TESTING CODE, NOT APPLICATION CODE !!!
        foreach R in cellIndexList do
            Occupants = getRowOccupancyList(R),
            stdio::write("\nRow occupants:", R, "  ", Occupants),
            % HWP 2019-11-26 RepList = replicantList::getAllReplicants(Occupants),
            RepList = replicantList::getReplicants(Occupants) otherwise [],
            stdio::write("\nReplicants: ", RepList)
        end foreach,
        foreach C in cellIndexList do
            stdio::write("\nCol ", C, "  ", getColOccupancyList(C))
        end foreach,
        stdio::nl,
        succeed.

%class predicates
%    tallyWinsPossibleAll : (positive PlayerO [out], positive PlayerX [out]).
clauses
    tallyWinsPossibleAll(WinsO:value, WinsX:value) :-
        WinsO = varM::new(0),
        WinsX = varM::new(0),
        VacantCells = getVacantCells(),
        foreach cell(R, C, _) in VacantCells do
            WinsO:value := WinsO:value + tallyWinsPossible(R, C, ownerO),
            WinsX:value := WinsX:value + tallyWinsPossible(R, C, ownerX)
        end foreach.

%class predicates
%    isWinPossibleAny : (positive Row, positive Column) determ.
clauses
    isWinPossibleAny(R, C) :-
        isOccupiedRow(R),
        !
        or
        isOccupiedColumn(C),
        !,
        list::length(getVacantDiagonalIds()) > 0,
        fail.
    isWinPossibleAny(_, _).

%class predicates
%    switchPlayer : (positive OwnerID) -> positive OtherOwnerId.
clauses
    switchPlayer(OwnerID) = OtherOwnerId :-
        if ownerO = OwnerID then
            OtherOwnerId = ownerX
        elseif ownerX = OwnerID then
            OtherOwnerId = ownerO
        else
            OtherOwnerId = OwnerID
        end if.

/******************************************************************************
                    SIMPLE CALCULATIONS and LIST OPERATIONS
******************************************************************************/
class predicates
    genPosList : (positive From, positive To) -> positive_list.
clauses
    genPosList(FromPos, ToPos) = [ P || P = fromToPos(FromPos, ToPos) ].

class predicates
    fromToPos : (positive From, positive To) -> positive P nondeterm.
clauses
    fromToPos(From, To) = From :-
        From <= To.
    fromToPos(From, To) = fromToPos(From + 1, To) :-
        From < To.

end implement game
