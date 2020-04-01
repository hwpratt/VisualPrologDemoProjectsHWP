% Copyright 2020 Harrison Pratt

implement taskWindow inherits applicationWindow
    open core, vpiDomains

constants
    mdiProperty : boolean = true.
    %
    taskWinStartMsg : string = #stringinclude("startUpMessage.txt").
    % HOWTO if the #stringinclude file is NOT in the project folder you will need to
    % qualify it with a folder name, e.g. #stringinclude(@"TaskWindow\someTextFile.txt")

clauses
    new() :-
        applicationWindow::new(),
        generatedInitialize().

%-------- MENU EVENTS ---------------------------------------------------------
class predicates
    onHelpAbout : window::menuItemListener.
clauses
    onHelpAbout(TaskWin, _MenuTag) :-
        _AboutDialog = aboutDialog::display(TaskWin).

predicates
    onFileExit : window::menuItemListener.
clauses
    onFileExit(_, _MenuTag) :-
        close().

%-------- PLAY GAMES of preset or custom size --------------------------
predicates
    onGamePlay3 : window::menuItemListener.
clauses
    onGamePlay3(Source, _MenuTag) :-
        _ = gameBoard::display(Source, 3).

predicates
    onGamePlay5 : window::menuItemListener.
clauses
    onGamePlay5(Source, _MenuTag) :-
        _ = gameBoard::display(Source, 5).

predicates
    onGamePlay7 : window::menuItemListener.
clauses
    onGamePlay7(Source, _MenuTag) :-
        _ = gameBoard::display(Source, 7).

predicates
    onGamePlayN : window::menuItemListener.
clauses
    onGamePlayN(_Source, _MenuTag) :-
        % HOWTO handle dialog return value on [OK] and [Cancel]
        if Size = askGameSize::display(applicationSession::getSessionWindow()) then
            % Closed dialog with [OK] pressed
            if Size >= tttGame::minBoardDimension then
                % Board size is valid
                _ = gameBoard::display(This, Size)
            else
                Title = "Error selecting board size for game",
                Msg = "Board size must be at least 3 cells across & down",
                _ = vpiCommonDialogs::messageBox(Title, Msg, mesbox_iconerror, mesbox_buttonsok, 1, mesbox_suspendapplication)
            end if
        else
            % askGameSize dialog closed with [Cancel]
        end if.

%-------- WINDOW HANDLING EVENTS ----------------------------------------------
predicates
    onShow : window::showListener.
clauses
    onShow(_, _CreationData) :-
        This:center(), % HOWTO Center application window on desktop
        MessageForm = messageForm::display(This),
        MessageForm:setVerticalSize(messageForm::parentRelative(1.0)), % HOWTO change size of Messages window
        % HOWTO change the font & maximum # of lines in the Messages window:
        MsgControl = MessageForm:getMessageControl(),
        MsgControl:setLines(1000), % 1000 is the default
        MsgControl:setFont(vpi::fontCreateByName("Lucida Console", 10)), % http://discuss.visual-prolog.com/viewtopic.php?t=8198
        stdio::write(taskWinStartMsg, "\n").

class predicates
    onDestroy : window::destroyListener.
clauses
    onDestroy(_).

predicates
    onSizeChanged : window::sizeListener.
clauses
    onSizeChanged(_) :-
        vpiToolbar::resize(getVPIWindow()).

% This code is maintained automatically, do not update it manually.
%  10:38:07-27.3.2020
predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setText("TicTacToeN"),
        setDecoration(titlebar([closeButton, maximizeButton, minimizeButton])),
        setBorder(sizeBorder()),
        setState([wsf_ClipSiblings]),
        whenCreated({  :- projectToolbar::create(getVpiWindow()) }),
        addSizeListener({  :- vpiToolbar::resize(getVpiWindow()) }),
        setMdiProperty(mdiProperty),
        menuSet(resMenu(resourceIdentifiers::id_TaskMenu)),
        addShowListener(onShow),
        addSizeListener(onSizeChanged),
        addDestroyListener(onDestroy),
        addMenuItemListener(resourceIdentifiers::id_help_about, onHelpAbout),
        addMenuItemListener(resourceIdentifiers::id_file_exit, onFileExit),
        addMenuItemListener(resourceIdentifiers::id_game_play_n, onGamePlayN),
        addMenuItemListener(resourceIdentifiers::id_game_play_7, onGamePlay7),
        addMenuItemListener(resourceIdentifiers::id_game_play_5, onGamePlay5),
        addMenuItemListener(resourceIdentifiers::id_game_play_3, onGamePlay3).
% end of automatic code

end implement taskWindow
