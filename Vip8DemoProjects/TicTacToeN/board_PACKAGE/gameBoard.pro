/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           gameBoard.pro
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

implement gameBoard
    inherits
        formWindow,
        tttGame % HOWTO note that 'gameboard' also inherits 'tttGame' functionality
    open core, gdiplus, gdiplus_native, vpiDomains

clauses
    display(Parent, NumCellsAcross) = Form :-
        Form = new(Parent, NumCellsAcross),
        Form:show().

clauses
    new(Parent, NumCellsAcross) :-
        formWindow::new(Parent),
        % HOWTO 'gameboard' inherits 'tttGame' so we must create a new instance of 'tttGame' for the 'gameBoard' to use
        tttGame::new(NumCellsAcross),
        generatedInitialize(), % <== this is automatically generated code
        % HOWTO do dialog customization after the dialog's objects are set up
        initializeBoardParameters(NumCellsAcross).

/******************************************************************************
    GAMEBOARD PROPERTY CLAUSES
-----------------------------------------------------------------------------*/
facts - propertyDB
    cellBorderColor_fact : ::color := erroneous.
    cellColorBF_fact : ::color := erroneous.
    cellColorFG_fact : ::color := erroneous.
    cellInset_fact : integer := erroneous.
    cellsAcross_fact : positive := erroneous.
    cellsDown_fact : positive := erroneous.
    playerColorO_fact : ::color := erroneous.
    playerColorX_fact : ::color := erroneous.
    bDrawCellBorders_fact : boolean := erroneous.

clauses % for properties
    cellBorderColor() = cellBorderColor_fact.  % getter
    cellBorderColor(COLOR) :-
        cellBorderColor_fact := COLOR.  % setter

    cellColorBG() = cellColorBF_fact.  % getter
    cellColorBG(COLOR) :-
        cellColorBF_fact := COLOR.  % setter

    cellColorFG() = cellColorFG_fact.  % getter
    cellColorFG(COLOR) :-
        cellColorFG_fact := COLOR.  % setter

    cellInset() = cellInset_fact.  % getter
    cellInset(INTEGER) :-
        cellInset_fact := INTEGER.  % setter

    cellsAcross() = cellsAcross_fact.  % getter
    cellsAcross(POSITIVE) :-
        cellsAcross_fact := POSITIVE.  % setter

    cellsDown() = cellsDown_fact.  % getter
    cellsDown(POSITIVE) :-
        cellsDown_fact := POSITIVE.  % setter

    playerColorO() = playerColorO_fact.  % getter
    playerColorO(COLOR) :-
        playerColorO_fact := COLOR.  % setter

    playerColorX() = playerColorX_fact.  % getter
    playerColorX(COLOR) :-
        playerColorX_fact := COLOR.  % setter

    bDrawCellBorders() = bDrawCellBorders_fact.  % getter
    bDrawCellBorders(BOOLEAN) :-
        bDrawCellBorders_fact := BOOLEAN.  % setter

/******************************************************************************
    SCREEN PAINTING PREDICATES
-----------------------------------------------------------------------------*/
facts - formSizeDB % these change on resize event
    clientRectSizeX : integer := erroneous.
    clientRectSizeY : integer := erroneous.
    cellSize : integer := erroneous.

predicates
    setWindowTextToShowCurrentPlayer : ().
clauses
    setWindowTextToShowCurrentPlayer() :-
        setText(string::concat("Player up: ", playerStr())).

predicates
    map_PntToRowCol : (vpiDomains::pnt, positive Row [out], positive Column [out]).
clauses
    map_PntToRowCol(pnt(X, Y), Row, Col) :-
        Row = cellsDown * Y div clientRectSizeY,
        Col = cellsAcross * X div clientRectSizeX.

constants
    markerInsetRatio : real = 0.15.

predicates
    map_RowCol_ToMarkerDrawingRectI : (positive Row, positive Column) -> rectI. % rectI used to draw 'X' and 'O' markers
clauses
    map_RowCol_ToMarkerDrawingRectI(Row, Col) = RectI :-
        L = cellSize * Col,
        T = cellSize * Row,
        Inset = math::max(1, math::round(cellSize * markerInsetRatio)),
        RectSize = cellSize - Inset * 2,
        RectI = rectI(L + Inset, T + Inset, RectSize, RectSize).

predicates
    drawGameGridLines : (graphics). % draws the '#' lines
clauses
    drawGameGridLines(G) :-
        Pen = pen::createColor(color::create(color::black), 2.0, gdiplus_native::unitPixel),
        foreach V = std::fromTo(1, cellsDown - 1) do
            Y = cellSize * V,
            G:drawLineI(Pen, pointI(0, Y), pointI(clientRectSizeX, Y))
        end foreach,
        foreach H = std::fromTo(1, cellsAcross - 1) do
            X = cellSize * H,
            G:drawLineI(Pen, pointI(X, 0), pointI(X, clientRectSizeY))
        end foreach.

predicates
    markerPenWidth : () -> real.
clauses
    markerPenWidth() = Width :-
        Width = math::max(1.0, cellSize / 15).

predicates
    drawMarkerInRectI : (markerDOM MarkerId, positive Row, positive Col, graphics).
clauses
    drawMarkerInRectI(Player, Row, Col, G) :-
        if Player = markerX then
            rectI(L, T, W, H) = map_RowCol_ToMarkerDrawingRectI(Row, Col),
            Pen = pen::createColor(playerColorX, markerPenWidth(), gdiplus_native::unitPixel),
            G:drawLineI(Pen, pointI(L, T), pointI(L + W, T + H)),
            G:drawLineI(Pen, pointI(L + W, T), pointI(L, T + H))
        elseif Player = markerO then
            RectI = map_RowCol_ToMarkerDrawingRectI(Row, Col),
            Pen = pen::createColor(playerColorO, markerPenWidth(), gdiplus_native::unitPixel),
            G:drawEllipseI(Pen, RectI)
        else
            exception::raise_error("Program logic error in ", predicate_fullname())
        end if.

predicates
    updateFormSizeDB : (window). % call onResize event
clauses
    updateFormSizeDB(Win) :-
        Win:getClientSize(W, H),
        clientRectSizeX := W,
        clientRectSizeY := H,
        cellSize := math::round(math::min(W, H) / cellsAcross).

predicates
    initializeBoardParameters : (positive BoardSize).
clauses
    initializeBoardParameters(BoardSize) :-
        cellsAcross := BoardSize,
        cellsDown := BoardSize,
        cellColorBG := color::create(color::lightblue),
        cellBorderColor := color::create(color::red),
        cellInset := 10, % inset from outer border of each calculated cell
        bDrawCellBorders := true,
        playerColorO := color::create(color::red),
        playerColorX := color::create(color::blue),
        setWindowTextToShowCurrentPlayer().

/******************************************************************************
    WINDOW MANAGEMENT PREDICATES
-----------------------------------------------------------------------------*/
predicates
    onShow : window::showListener.
clauses
    onShow(Source, _Data) :-
        centerTo(applicationSession::getSessionWindow()),
        updateFormSizeDB(Source).

predicates
    onSize : window::sizeListener.
clauses
    onSize(Source) :-
        % HOWTO force the game board to remain square on resizing
        rct(L, T, _R, _B) = Source:getClientRect(),
        Source:getClientSize(Width, Height),
        NewSize = math::min(Width, Height),
        Source:setClientRect(rct(L, T, L + NewSize, T + NewSize)),
        updateFormSizeDB(Source),
        invalidate().  % HOWTO force form to repaint itself

predicates
    onPaint : window::paintResponder.
clauses
    onPaint(_Source, _Rectangle, GDI) :-
        HDC = GDI:getNativeGraphicContext(IsReleaseNeeded),
        Graphics = graphics::createFromHDC(HDC),
        Graphics:smoothingMode := gdiplus_native::smoothingModeAntiAlias, % the default is unsmoothed
        %-- invoke drawing here
        drawGameGridLines(Graphics),
        foreach rcm(R, C, M) in rcmListOccupied() do
            drawMarkerInRectI(M, R, C, Graphics)
        end foreach,
        %-- end of drawing
        GDI:releaseNativeGraphicContext(HDC, IsReleaseNeeded).

predicates
    onMouseUp : window::mouseUpListener.
clauses
    onMouseUp(_Source, PNT, _ShiftControlAlt, Button) :-
        map_PntToRowCol(PNT, Row, Col),
        % PLACE MARKER FOR currPlayer where clicked on left-click
        if mouse_BUTTON_LEFT = Button then
            if noMovesRemain() then
                vpiCommonDialogs::note("This TicTacToeN game is OVER!", "There are NO MORE MOVES to make.")
            elseif tryPlaceMarker(player(), Row, Col) then
                invalidate(), % HOWTO force form to repaint itself after drawing a marker
                setWindowTextToShowCurrentPlayer(),
                % test for 'game won' state and declare the winner
                if _Cells = tryGetWinningCells(Row, Col) and WinnerStr = playerWinnerStr() then
                    setText(string::format("Game has been won by player %", WinnerStr)),
                    vpiCommonDialogs::note("We have a Winner!", string::format("Player %", WinnerStr))
                end if
            else
                % do nothing if left-click on occupied cell
            end if
            % COUNT WAYS TO WIN for currPlayer if right-click
        elseif mouse_BUTTON_RIGHT = Button then
            N = countWaysToWin(Row, Col),
            Title = string::format("How many different ways can player '%' win?", playerStr()), % HOWTO handle singulars & plurals in messages
            Msg =
                list::tryGetNth(N, ["There is NO WAY to win using this cell!", "There is just ONE WAY to win using this cell."])
                    otherwise string::format("There are % different ways for '%' to win that use this cell.", N, playerStr()),
            vpiCommonDialogs::note(Title, Msg)
        end if.

% This code is maintained automatically, do not update it manually.
%  08:32:15-28.8.2018
predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setText("gameBoard"),
        setRect(rct(50, 40, 300, 290)),
        setDecoration(titlebar([closeButton, maximizeButton, minimizeButton])),
        setBorder(sizeBorder()),
        setState([wsf_ClipSiblings, wsf_ClipChildren]),
        menuSet(noMenu),
        addMouseUpListener(onMouseUp),
        addShowListener(onShow),
        addSizeListener(onSize),
        setPaintResponder(onPaint).

% end of automatic code
end implement gameBoard
