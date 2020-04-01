/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           tttGame.pro
Project:        TicTacToeN
Package:        pack_GAME
Keywords:
Created:        2020-03-29
Modified:
Purpose:        Create the tttGame object containg the game board array used in playing the game.
                Provide predicates used for scoring the game.
Comments:       Is inherited by the 'gameBoard' during play.
Examples:
******************************************************************************/

implement tttGame
    open core

domains
    playerDOM = markerDOM.

clauses
    new(BoardSize) :-
        gameBoard := array2M::newInitialize(BoardSize, BoardSize, markerNone), % HOWTO fill board array with empty markers
        boardSizeX := gameBoard:sizeX, % board is square, so can use sizeX or sizeY
        boardSizeY := gameBoard:sizeY, % redundant, but used elsewhere for clarity
        boardMaxIndexX := boardSizeX - 1,
        boardMaxIndexY := boardSizeY - 1,
        currPlayer := markerX, % first player is always 'X'
        openCells := BoardSize * BoardSize, % count open cells
        % set up rules to win game
        if BoardSize = 3 then
            numToWin := BoardSize
        elseif BoardSize > 3 then
            numToWin := BoardSize - 1
        elseif BoardSize < 3 then
            vpiCommonDialogs::error(predicate_fullname(),
                string::format("Board size must be at least %.  You entered '%'", minBoardDimension, BoardSize)),
            exception::raise_error(predicate_fullname())
        end if.

facts - boardDB
    gameBoard : array2M{markerDOM} := erroneous.
    % Note: boardSize and boardMaxIndex in this application are always the same for X & Y dimensions
    % but separate facts for X & Y are used for code clarity.
    boardSizeX : positive := erroneous.
    boardSizeY : positive := erroneous.
    boardMaxIndexX : positive := erroneous.
    boardMaxIndexY : positive := erroneous.

facts - gameDB
    currPlayer : markerDOM := erroneous. % player about to make a move
    lastPlayer : markerDOM := erroneous. % last player to make a move, use to report winner
    winningPlayer : markerDOM := erroneous.
    numToWin : positive := erroneous. % number of contiguous cells needed to win
    openCells : positive := erroneous. % number of unplayed cells, counts down with each marker placed

/******************************************************************************
    CLAUSES FOR INTERFACE PREDICATES
-----------------------------------------------------------------------------*/
clauses
    tryPlaceMarker(Marker, Row, Column) :-
        %
        isErroneous(winningPlayer), % block further play after someone has won
        openCells > 0, % block further play when all cells have been played
        %
        try
            gameBoard:get(Row, Column) = markerNone, % FAIL if an occupied cell
            gameBoard:set(Row, Column, Marker),
            lastPlayer := Marker,
            setNextPlayer(Marker),
            openCells := openCells - 1
        catch _ do
            Msg = string::format("Row '%' or Column '%' exceeds board size of '%'", Row, Column, boardSizeX),
            vpiCommonDialogs::error(predicate_fullname(), Msg),
            fail
        end try.

    tryGetWinningCells(Row, Column) = RCList :-
        % HOWTO check for winning play.
        % This is called after a piece is newly placed on the board
        % The cells are scanned for a minimum number of cells in a row, column or diagonal
        Marker = gameBoard:get(Row, Column),
        Win = { (TT) :- hasRunOf(TT, Marker, numToWin) }, % HOWTO use anonymous predicate to make code below more concise
        if Win(rowMarkers(Row)) then
            RCList = rcRowCells(Row)
        elseif Win(colMarkers(Column)) then
            RCList = rcColCells(Column)
        elseif Win(diagMarkers_DnRt(Row, Column)) then
            RCList = rcDiagonal_DnRt(Row, Column)
        elseif Win(diagMarkers_UpRt(Row, Column)) then
            RCList = rcDiagonal_UpRt(Row, Column)
        else
            fail
        end if,
        winningPlayer := lastPlayer.

    countWaysToWin(Row, Column) = NumWays :-
        % Collect list of booleans, where
        %     T if cell is empty or occupied by the current Player, and
        %     F if cell is occupied by the opposing player
        Opponent = otherPlayer(currPlayer),
        TF_List =
            { (MM) =
                [ B ||
                    M in MM,
                    B = toBoolean(M <> Opponent) % useful cell is empty or occupied by currPlayer
                ]
            },
        AddWay =
            { (MM) = Add :-
                if hasRunOf(TF_List(MM), true, numToWin) then
                    % has a run of TRUEs, so ponentially winnable
                    Add = 1
                else
                    Add = 0
                end if
            },
        % Sum count of winnable markers in various directions
        NumWays = AddWay(rowMarkers(Row)) + AddWay(colMarkers(Column)) + AddWay(diagMarkers_DnRt(Row, Column)) + AddWay(diagMarkers_UpRt(Row, Column)).

clauses
    player() = currPlayer.

    playerStr() = toMarkerStr(currPlayer).

%    playerWinner() = notErroneous(winningPlayer).
    playerWinner() = winningPlayer :-
        not(isErroneous(winningPlayer)).

%    playerWinnerStr() = toMarkerStr(notErroneous(winningPlayer)). % VIP 9x syntax
    playerWinnerStr() = toMarkerStr(winningPlayer) :-
        % VIP 8x syntax
        not(isErroneous(winningPlayer)).

    rowMarkers(Row) =
        [ M ||
            Col = std::fromTo(0, boardMaxIndexX),
            M = gameBoard:get(Row, Col)
        ].

    colMarkers(Column) =
        [ M ||
            Row = std::fromTo(0, boardMaxIndexY),
            M = gameBoard:get(Row, Column)
        ].

    diagMarkers_UpRt(Row, Column) = [ gameBoard:get(R, C) || rc(R, C) in rcDiagonal_UpRt(Row, Column) ].

    diagMarkers_DnRt(Row, Column) = [ gameBoard:get(R, C) || rc(R, C) in rcDiagonal_DnRt(Row, Column) ].

    rcmListAll() =
        [ rcm(Row, Col, Marker) ||
            Row = std::fromTo(0, boardMaxIndexY),
            Col = std::fromTo(0, boardMaxIndexX),
            Marker = gameBoard:get(Row, Col)
        ].

    rcmListOccupied() =
        [ rcm(Row, Col, Marker) ||
            Row = std::fromTo(0, boardMaxIndexY),
            Col = std::fromTo(0, boardMaxIndexX),
            Marker = gameBoard:get(Row, Col),
            Marker <> markerNone
        ].

    rcmListUnoccupied() =
        [ rcm(Row, Col, Marker) ||
            Row = std::fromTo(0, boardMaxIndexY),
            Col = std::fromTo(0, boardMaxIndexX),
            Marker = gameBoard:get(Row, Col),
            Marker = markerNone
        ].

    onBoard(Row, Column) :-
        Column <= boardMaxIndexX,
        Row <= boardMaxIndexY.

    noMovesRemain() :-
        openCells = 0.

    emitBoard() :-
        % used only for intial testing and debugging
        stdio::nl,
        foreach Row = std::fromTo(0, boardMaxIndexY) do
            MM = toMarkerStrings(rowMarkers(Row)),
            stdio::write(string::concatWithDelimiter(MM, " "), "\n")
        end foreach.  % row.

/******************************************************************************
    LOCAL SUPPORT PREDICATES
-----------------------------------------------------------------------------*/
predicates
    toMarkerStr : (markerDOM) -> string PlayerStr.
clauses
    toMarkerStr(markerX) = "X".
    toMarkerStr(markerO) = "O".
    toMarkerStr(markerNone) = " ".

predicates
    toMarkerStrings : (markerListDOM Markers) -> string_list MarkerStrings.
clauses
    toMarkerStrings(MM) = [ toMarkerStr(M) || M in MM ].

predicates
    setNextPlayer : (playerDOM CurrPlayer).
clauses
    setNextPlayer(markerX) :-
        currPlayer := markerO.
    setNextPlayer(markerO) :-
        currPlayer := markerX.
    setNextPlayer(markerNone) :-
        exception::raise_error("Program logic error in ", predicate_fullname()).

predicates
    otherPlayer : (playerDOM) -> playerDOM.
clauses
    otherPlayer(markerX) = markerO.
    otherPlayer(markerO) = markerX.
    otherPlayer(markerNone) = _ :-
        exception::raise_error(predicate_fullname(), " is not to be used with ", toString(markerNone)).

%------------------------------------------------------------------------------
predicates
    rcRowCells : (positive Row) -> rcListDOM RCList.
clauses
    rcRowCells(Row) = [ rc(Row, C) || C = std::fromTo(0, boardMaxIndexX) ].

predicates
    rcColCells : (positive Col) -> rcListDOM RCList.
clauses
    rcColCells(Col) = [ rc(R, Col) || R = std::fromTo(0, boardMaxIndexY) ].

predicates
    rcDiagonal_DnRt : (positive Row, positive Col) -> rcListDOM RCList.
clauses
    rcDiagonal_DnRt(R0, C0) = RCList :-
        % above R0,C0 and to left
        UpStep = math::min(R0, C0),
        CellsUpLt =
            [ rc(R, C) ||
                D = std::downTo(UpStep, 1),
                R = R0 - D,
                C = C0 - D
            ],
        % R0,C0 and down to right
        DnStep = math::min(boardMaxIndexX - C0, boardMaxIndexY - R0),
        CellsDnRt =
            [ rc(R, C) ||
                D = std::fromTo(0, DnStep),
                R = R0 + D,
                C = C0 + D
            ],
        RCList = list::append(CellsUpLt, CellsDnRt).

predicates
    rcDiagonal_UpRt : (positive Row, positive Col) -> rcListDOM RCList.
clauses
    rcDiagonal_UpRt(R0, C0) = RCList :-
        % R0,C0 and up to right
        UpStep = math::min(R0, boardMaxIndexY - C0),
        CellsUpRt =
            [ rc(R, C) ||
                D = std::downTo(UpStep, 0),
                R = R0 - D,
                C = C0 + D
            ],
        % below R0,C0 down to left
        DnStep = math::min(C0, boardMaxIndexY - R0),
        CellsDnLt =
            [ rc(R, C) ||
                D = std::fromTo(1, DnStep),
                R = R0 + D,
                C = C0 - D
            ],
        RCList = list::append(CellsUpRt, CellsDnLt).

/******************************************************************************

-----------------------------------------------------------------------------*/
%class predicates
%    countMember : (T, T*) -> positive CountOfTerm.
%clauses
%    countMember(T, TT) = N:value :-
%        N = varM_integer::new(0),
%        foreach E = list::getMember_nd(TT) do
%            if E = T then
%                N:inc()
%            end if
%        end foreach.
%
class predicates
    hasRunOf : (T* TermList, T TermToCount, positive CountWant) determ.
    % Succeeds if there are >= CountWant CONSECUTIVE occurence of TermToCOunt in TermList.
    % If CountWant = 0 then succeeds if there are NO occurences of TermToCount.
    % If CountWant = 1 then is functionally equivalent to list::isMember(Elem,ElemLIST).
clauses
    hasRunOf(TT, Seek, CountWant) :-
        hasRunOf_aux(TT, Seek, 0, CountWant).

class predicates
    hasRunOf_aux : (T* TermList, T SeekTerm, positive CurrN, positive WantN) determ.
clauses
    hasRunOf_aux(_, _, N, N) :-
        !.
    hasRunOf_aux([Seek | T], Seek, N, Q) :-
        !,
        hasRunOf_aux(T, Seek, 1 + N, Q).
    hasRunOf_aux([_ | T], Seek, _CurrN, Q) :-
        !,
        hasRunOf_aux(T, Seek, 0, Q).

end implement tttGame
