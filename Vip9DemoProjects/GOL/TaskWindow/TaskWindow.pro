% Harrison Pratt 2020

implement taskWindow inherits applicationWindow
    open core, vpiDomains

constants
    mdiProperty : boolean = true.

clauses
    new() :-
        applicationWindow::new(),
        generatedInitialize().

predicates
    onShow : window::showListener.
clauses
    onShow(Source, _CreationData) :-
        Source:getClientSize(_W, H),
        Source:setClientSize(1000, H),
        Source:center(),
        _MessageForm = messageForm::display(Source).

class predicates
    onDestroy : window::destroyListener.
clauses
    onDestroy(_).

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

predicates
    onSizeChanged : window::sizeListener.
clauses
    onSizeChanged(_) :-
        vpiToolbar::resize(getVPIWindow()).

constants
    stringPlayHints = #stringinclude(@"life_PACK\gamePlayHints.txt").

predicates
    onGameOpenGameWindow : window::menuItemListener.
clauses
    onGameOpenGameWindow(Source, _MenuTag) :-
        Source:setState([wsf_maximized]),
        stdio::write("\n", stringPlayHints, "\n"),
        _ = vpi::processEvents(),
        _ = gameSpace::display(Source).

constants
    stringGameRules = #stringinclude(@"life_PACK\gameRules.txt"). % @"C:\Users\Owner\Documents\Vip9x\9x_TESTING\GOL\life_PACK\gameRules.txt"

predicates
    onGameShowGameRules : window::menuItemListener.
clauses
    onGameShowGameRules(_Source, _MenuTag) :-
        stdio::write("\n", stringGameRules, "\n").

constants
    stringHowtoPlay = #stringinclude(@"life_PACK\gameHowToPlay.txt").

predicates
    onGameShowHowToPlay : window::menuItemListener.
clauses
    onGameShowHowToPlay(_Source, _MenuTag) :-
        stdio::write("\n", stringHowToPlay, "\n").

predicates
    onFileExplore : window::menuItemListener.
clauses
    onFileExplore(_Source, _MenuTag) :-
        mainExe::getFileName(AppDir, _),
        shell_api::shellExecute(nullWindow, "open", "explorer.exe", AppDir).

% This code is maintained automatically, do not update it manually.
%  09:11:38-16.5.2020
predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setText("GOL"),
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
        addMenuItemListener(resourceIdentifiers::id_game_open_game_window, onGameOpenGameWindow),
        addMenuItemListener(resourceIdentifiers::id_game_show_game_rules, onGameShowGameRules),
        addMenuItemListener(resourceIdentifiers::id_game_show_how_to_play, onGameShowHowToPlay),
        addMenuItemListener(resourceIdentifiers::id_file_explore, onFileExplore).
% end of automatic code

end implement taskWindow
