% Copyright 2018-2020 Harrison Pratt

implement tttGame
    open core

clauses % constructors
    new(BoardSize) :-
%        boardSize := BoardSize,
        initGameBoard(BoardSize).

%------------------------------------------------------------------------------
class facts - boardDB
    boardSize : integer := erroneous.
    numToWin : integer := erroneous.
    cellFact : (integer, integer, playerDOM).

class predicates
    playerMarker : (playerDOM, string [out]).
clauses
    playerMarker(playerNone, " ").
    playerMarker(playerX, "X").
    playerMarker(playerO, "O").

class predicates
    initGameBoard : (integer BoardSize).
clauses
    initGameBoard(BoardSize) :-
        retractFactDb(boardDB),
        boardSize := BoardSize,
        foreach R = std::fromTo(1, boardSize) do
            foreach C = std::fromTo(1, boardSize) do
                assert(cellFact(R, C, playerNone))
            end foreach % column
        end foreach, % row
        % Number needed to win is not always = boardSize
        if boardSize = 3 then
            numToWin := 3
        else
            numToWIn := boardSize - 1
        end if.

%------------------------------------------------------------------------------
class predicates
    mkDiag_UpToRt : (integer Row, integer Col) -> rcListDOM RCList.
clauses
    mkDiag_UpToRt(R0, C0) = RCList :-
        DnD = boardSize - R0,
        LtD = C0 - 1,
        DminL = math::min(DnD, LtD),
        LeftRCs =
            [ rc(R, C) ||
                D = std::fromTo(1, DminL),
                R = R0 + D,
                C = C0 - D,
                isValidRC(R, C)
            ],
        UpD = R0 - 1,
        RtD = boardSize - R0,
        DminR = math::min(UpD, RtD),
        RightRCs =
            [ rc(R, C) ||
                D = std::fromTo(1, DminR),
                R = R0 - D,
                C = C0 + D,
                isValidRC(R, C)
            ],
        RCList = list::sort(list::appendList([LeftRCs, [rc(R0, C0)], RightRCs])).

class predicates
    mkDiag_DnToRt : (integer Row, integer Col) -> rcListDOM RCList.
clauses
    mkDiag_DnToRt(R0, C0) = RCList :-
        DnD = boardSize - R0,
        LtD = C0 - 1,
        DminL = math::min(DnD, LtD),
        RtRCs =
            [ rc(R, C) ||
                D = std::fromTo(1, DminL),
                R = R0 + D,
                C = C0 + D,
                isValidRC(R, C)
            ],
        UpD = R0 - 1,
        RtD = boardSize - R0,
        DminR = math::min(UpD, RtD),
        LtRCs =
            [ rc(R, C) ||
                D = std::fromTo(1, DminR),
                R = R0 - D,
                C = C0 - D,
                isValidRC(R, C)
            ],
        RCList = list::sort(list::appendList([LtRCs, [rc(R0, C0)], RtRCs])).

class predicates
    mkRowCellList : (integer Row) -> rcListDOM.
clauses
    mkRowCellList(R0) = [ rc(R0, C) || C = std::fromTo(1, boardSize) ].

class predicates
    mkColCellList : (integer Column) -> rcListDOM.
clauses
    mkColCellList(C0) = [ rc(R, C0) || R = std::fromTo(1, boardSize) ].

%------------------------------------------------------------------------------
class predicates
    hasRunOf : (T, T*, integer CountWant) determ.
clauses
    hasRunOf(T, TT, CountWant) :-
        hasRunOf_aux(T, TT, 0, CountWant).

class predicates
    hasRunOf_aux : (T, T*, integer CurrCount, integer CountWant) determ.
clauses
    hasRunOf_aux(_, [], CurrN, WantN) :-
        !,
        CurrN >= WantN.
    hasRunOf_aux(E, [H | TT], CurrCount, N) :-
        if E = H then
            if N - CurrCount = 1 then
                succeed()
            else
                hasRunOf_aux(E, TT, 1 + CurrCount, N)
            end if
        else
            hasRunOf_aux(E, TT, 0, N)
        end if.

class predicates
    isValidRC : (integer Row, integer Col) determ.
clauses
    isValidRC(Row, Col) :-
        OK =
            { (V) :-
                V > 0,
                V <= boardSize
            },
        OK(Row),
        OK(Col).

%------------------------------------------------------------------------------
    playersInRow(Row) =
        [ P ||
            rc(R, C) in mkRowCellList(Row),
            cellFact(R, C, P)
        ].

    playersInColumn(Col) =
        [ P ||
            rc(R, C) in mkColCellList(Col),
            cellFact(R, C, P)
        ].

    playersInDiag_DnToRt(R, C) =
        [ P ||
            rc(R, C) in mkDiag_DnToRt(R, C),
            cellFact(R, C, P)
        ].

    playersInDiag_UpToRt(Row, Col) =
        [ P ||
            rc(R, C) in mkDiag_UpToRt(Row, Col),
            cellFact(R, C, P)
        ].

%-----------
    tryPlaceMarker(R, C, PutPlayer) :-
        cellFact(R, C, PrevPlayer),
        !,
        PrevPlayer = playerNone,
        retractAll(cellFact(R, C, _)),
        assert(cellFact(R, C, PutPlayer)).

    playerHasWonAfterPlayingThisCell(P, R, C) = PlayersCells :-
        if hasRunOf(P, playersInColumn(C), numToWin) then
            PlayersCells =
                [ rc(Rp, C) ||
                    rc(Rp, C) in mkColCellList(C),
                    cellFact(Rp, C, P)
                ]
        elseif hasRunOf(P, playersInRow(R), numToWin) then
            PlayersCells =
                [ rc(R, Cp) ||
                    rc(R, Cp) in mkRowCellList(R),
                    cellFact(R, Cp, P)
                ]
        elseif hasRunOf(P, playersInDiag_DnToRt(R, C), numToWin) then
            PlayersCells =
                [ rc(Rp, Cp) ||
                    rc(Rp, Cp) in mkDiag_DnToRt(R, C),
                    cellFact(Rp, Cp, P)
                ]
        elseif hasRunOf(P, playersInDiag_UpToRt(R, C), numToWin) then
            PlayersCells =
                [ rc(Rp, Cp) ||
                    rc(Rp, Cp) in mkDiag_UpToRt(R, C),
                    cellFact(Rp, Cp, P)
                ]
        else
            fail
        end if.

    couldWinTheseCells(TryPlayer, CellList) :-
        N = varM_integer::new(0),
        foreach cell(_, _, CellPlayer) in CellList do
            if CellPlayer = TryPlayer or CellPlayer = playerNone then
                N:inc()
            end if
        end foreach,
        N:value >= numToWin.

end implement tttGame
