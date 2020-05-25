% Harrison Pratt 2020

implement gameSpace inherits formWindow
    open core, vpiDomains

clauses
    display(Parent) = Form :-
        Form = new(Parent),
        Form:show().

clauses
    new(Parent) :-
        formWindow::new(Parent),
        generatedInitialize(),
        gameArray := array2M::newInitialize(gameDimension, gameDimension, false).

%------------------------------------------------------------------------------
%
facts - gameDB
    cellDimension : real := erroneous.
    %
    gameArray : array2M{boolean} := erroneous.
    gameCycles : integer := 100. % count down to 0.  % should be 100+ when not testing
    gameDimension : integer := 100. % Number of Rows and Columns
    gameIndexMax : integer := gameDimension - 1.
    gamePauseMSec : integer := 100. % pause between each game cycle
    gameStop : boolean := false. % use to stop a long game cycle

constants
    colorBG : color = color::white.
    colorPiece : color = color::darkRed.
    colorLine : color = color::lightGray.

predicates
    gameLoop : (window, positive Cycles).
clauses
    gameLoop(Window, CyclesLeft) :-
        if CyclesLeft > 0 and gameStop = false then
            NumberApplied = applyRulesToMatrix(),
            Window:setText(string::format("Cycles remaining: %", CyclesLeft - 1)),
            if NumberApplied > 0 then
                _ = vpi::processEvents(),
                programControl::sleep(gamePauseMSec), % so can better see the 'moves' as they happen
                gameLoop(Window, CyclesLeft - 1)
            else
                Window:setText(string::format("No more moves remain after % moves.  Game is over.", gameCycles - CyclesLeft)),
                vpiCommonDialogs::note(predicate_fullname(), "No more moves remain.\n\nPress F9 to restart using current markers")
            end if
        end if.

predicates
    applyRulesToMatrix : () -> positive CountOfCellsUpdated.
clauses
    applyRulesToMatrix() = list::length(BirthsDeaths) :-
        BirthsDeaths =
            [ BD ||
                rowCol_nd(R, C),
                BD = getLiveOrDie(R, C)
            ],
        foreach tuple(R, C, B) in BirthsDeaths do
            gameArray:set(R, C, B),
            invalidate(mapRowCol_toRCT(R, C))
        end foreach.

domains
    changeToState_DOM = tuple{integer Row, integer Col, boolean NewState}.

predicates
    getLiveOrDie : (positive Row, positive Col) -> changeToState_DOM determ. % Fail if state is unchanged
    % https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules
    /*
    Any live cell with 0 or 1 live neighbors becomes dead, because of underpopulation
    Any live cell with 2 or 3 live neighbors stays alive, because its neighborhood is just right
    Any live cell with more than 3 live neighbors becomes dead, because of overpopulation
    Any dead cell with exactly 3 live neighbors becomes alive, by reproduction
    */
clauses
    getLiveOrDie(Row, Col) = NewState :-
        AliveN = liveNeighborCount(Row, Col),
        IsAlive = { () :- gameArray:get(Row, Col) = true },
        if not(IsAlive()) and AliveN = 3 then
            NewState = tuple(Row, Col, true)
        elseif IsAlive() and not(inRange(AliveN, 2, 3)) then
            NewState = tuple(Row, Col, false) % dies if lonely or over-crowded
        else
            fail % no change needed
        end if.

%------------------------------------------------------------------------------
%
predicates
    drawGrid : (window W, graphics G).
clauses
    drawGrid(W, G) :-
        G:clear(color::create(colorBG)),
        Pen = pen::createColor(color::create(colorLine), 1, gdiplus_native::unitPixel),
        rct(L, _T, R, B) = gui_api::getClientRect(W:getVpiWindow()),
        Step = convert(real32, (R - L) / gameDimension),
        foreach Y = fromToStepR32(Step, B, Step) do
            G:drawLineF(Pen, 0, Y, R, Y)
        end foreach,
        foreach X = fromToStepR32(Step, R, Step) do
            G:drawLineF(Pen, X, 0, X, B)
        end foreach.

predicates
    drawMarkers : (graphics Graphics).
clauses
    drawMarkers(G) :-
        Brush = solidBrush::create(color::create(colorPiece)),
        foreach Row = std::fromTo(0, gameIndexMax) do
            foreach Col = std::fromTo(0, gameIndexMax) do
                if gameArray:get(Row, Col) = true then
                    G:fillRectangleF(Brush, mapRowCol_toRECTF(Row, Col))
                end if
            end foreach
        end foreach.

predicates
    mapPnt_toRowCol : (vpiDomains::pnt PNT, integer Row [out], integer Col [out]).
clauses
    mapPnt_toRowCol(pnt(X, Y), Row, Col) :-
        Row = math::trunc(convert(real, Y) / cellDimension),
        Col = math::trunc(convert(real, X) / cellDimension).

predicates
    mapRowCol_toRECTF : (integer Row, integer Col) -> gdiplus::rectF RectF.
clauses
    mapRowCol_toRECTF(Row, Col) = RectF :-
        L = convert(real32, Col * cellDimension),
        T = convert(real32, Row * cellDimension),
        Size32 = convert(real32, cellDimension),
        RectF = gdiplus::rectF(L, T, Size32, Size32).

predicates
    mapRowCol_toRCT : (integer Row, integer Col) -> vpiDomains::rct RCT.
clauses
    mapRowCol_toRCT(Row, Col) = RCT :-
        L = Col * cellDimension,
        T = Row * cellDimension,
        RCT = vpiDomains::rct(math::trunc(L), math::trunc(T), 1 + math::ceil(L + cellDimension), 1 + math::ceil(T + cellDimension)).

%------------------------------------------------------------------------------
%
predicates
    liveNeighborCount : (integer Row, integer Col) -> integer N.
clauses
    liveNeighborCount(Row, Col) = N :-
        NeighborCells =
            [ 1 ||
                R in neighborRows(Row),
                C in neighborCols(Col),
                if R = Row and C = Col then
                    fail % a cell cannot be its own neighbor
                else
                    gameArray:get(R, C) = true
                end if
            ],
        N = list::length(NeighborCells).

predicates
    neighborRows : (integer Row) -> integer_list ValidRowList.
clauses
    neighborRows(R) = [ Row || Row = std::fromTo(math::max(0, R - 1), math::min(gameIndexMax, R + 1)) ].

predicates
    neighborCols : (integer Col) -> integer_list ValidColList.
clauses
    neighborCols(C) = [ Col || Col = std::fromTo(math::max(0, C - 1), math::min(gameIndexMax, C + 1)) ].

predicates
    inRange : (T TestTerm, T Min, T Max) determ.
clauses
    inRange(T, Min, Max) :-
        Min <= T,
        T <= Max.

predicates
    fromToStepR32 : (real32 From, real To, real32 Step) -> real32 R nondeterm.
clauses
    fromToStepR32(From, To, _Step) = From :-
        From <= To.
    fromToStepR32(From, To, Step) = fromToStepR32(From + Step, To, Step) :-
        From < To.

%------------------------------------------------------------------------------
%
predicates
    rcList_ALIVE : () -> rcList_DOM.
clauses
    rcList_ALIVE() =
        [ rc(R, C) ||
            rowCol_nd(R, C),
            gameArray:get(R, C) = true
        ].

predicates
    rowCol_nd : (integer Row [out], integer Col [out]) nondeterm.
clauses
    rowCol_nd(R, C) :-
        R = std::fromTo(0, gameIndexMax),
        C = std::fromTo(0, gameIndexMax).

%------------------------------------------------------------------------------
%
predicates
    onShow : window::showListener.
clauses
    onShow(_Source, _Data) :-
        getClientSize(Width, _Height),
        cellDimension := Width / gameDimension,
        centerTo(applicationSession::getSessionWindow()).

predicates
    onMouseUp : window::mouseUpListener.
clauses
    onMouseUp(Source, Point, _ShiftControlAlt, Button) :-
        mapPnt_toRowCol(Point, R, C),
        if Button = vpiDomains::mouse_button_LEFT then
            CurrState = gameArray:get(R, C),
            NewState = toBoolean(CurrState = false), % toggle cell Alive <--> Dead
            gameArray:set(R, C, NewState),
            invalidate(mapRowCol_toRCT(R, C)) % Don't redraw the entire window when changing cells, just invalidated the cell rectangle
        elseif Button = vpiDomains::mouse_button_RIGHT and PatternList = selectStandardPattern::display(Source) then
            CurrRow = varM_integer::new(R),
            foreach II in PatternList do
                foreach I in II do
                    CurrCol = C + I,
                    if inRange(CurrRow:value, 0, gameIndexMax) and inRange(CurrCol, 0, gameIndexMax) then
                        gameArray:set(CurrRow:value, CurrCol, true),
                        invalidate(mapRowCol_toRCT(CurrRow:value, C + I))
                    end if
                end foreach,
                CurrRow:inc()
            end foreach
        end if.

predicates
    onPaint : window::paintResponder.
clauses
    onPaint(Source, _Rectangle, GDI) :-
        HDC = GDI:getNativeGraphicContext(IsReleaseNeeded),
        Graphics = graphics::createFromHDC(HDC),
        Graphics:smoothingMode := gdiplus_native::smoothingModeAntiAlias, % the default is unsmoothed
        %-- start drawing
        drawGrid(Source, Graphics),
        drawMarkers(Graphics),
        %-- end of drawing
        GDI:releaseNativeGraphicContext(HDC, IsReleaseNeeded).

predicates
    onMenuItem : window::menuItemListener.
clauses
    onMenuItem(Source, MenuTag) :-
        /* ----- resourceIdentifiers.i -----
            id_game = 10006.    % life_PACK\gameMenu.mnu
            id_game_start_game = 10007.    % life_PACK\gameMenu.mnu
            id_game_start_game_1_million_cycles = 10008.    % life_PACK\gameMenu.mnu
            id_game_save_cells = 10009.    % life_PACK\gameMenu.mnu
            id_game_load_cells = 10010.    % life_PACK\gameMenu.mnu
            id_game_kill_all_cells = 10011.    % life_PACK\gameMenu.mnu
            id_game_set_delay_interval = 10012.    % life_PACK\gameMenu.mnu
            id_game_close = 10013.    % life_PACK\gameMenu.mnu
        */
        if resourceIdentifiers::id_game_start_game = MenuTag then
            gameStop := false,
            gameCycles := 100, % default setting is 100 cycles
            gameLoop(Source, gameCycles)
            %
        elseif resourceIdentifiers::id_game_start_game_1_million_cycles = MenuTag then
            gameStop := false,
            gameCycles := 1000000, % default setting is 100 cycles
            gameLoop(Source, gameCycles)
            %
        elseif resourceIdentifiers::id_game_save_cells = MenuTag then
            gameStoreDB::saveCellsDB(rcList_ALIVE())
            %
        elseif resourceIdentifiers::id_game_load_cells = MenuTag then
            if RCList = gameStoreDB::rclistFromDbFile(false, gameDimension) then
                foreach rc(R, C) in RCList do
                    gameArray:set(R, C, true)
                end foreach,
                invalidate()
            end if
            %
        elseif resourceIdentifiers::id_game_close = MenuTag then
            destroy()
            %
        end if.

predicates
    onDestroy : window::destroyListener.
clauses
    onDestroy(Source) :-
        Source:getParent():setState([wsf_restored]).

predicates
    onKeyUp : window::keyUpResponder.
clauses
    onKeyUp(_Source, Key, _ShiftControlAlt) = window::defaultKeyUpHandling :-
        if Key = k_esc then
            gameStop := true
        end if.

% This code is maintained automatically, do not update it manually.
%  10:50:48-15.5.2020
predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setText("gameSpace"),
        setRect(rct(50, 100, 500, 550)),
        setDecoration(titlebar([closeButton])),
        setBorder(fixedBorder()),
        setState([wsf_ClipSiblings, wsf_ClipChildren]),
        menuSet(resMenu(resourceIdentifiers::mnu_gameMenu)),
        addDestroyListener(onDestroy),
        addMenuItemListener(onMenuItem),
        addMouseUpListener(onMouseUp),
        addShowListener(onShow),
        setKeyUpResponder(onKeyUp),
        setPaintResponder(onPaint).
% end of automatic code

end implement gameSpace
