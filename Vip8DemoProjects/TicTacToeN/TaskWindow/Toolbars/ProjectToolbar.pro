% Copyright 2020 Harrison Pratt

implement projectToolbar
    open vpiDomains, vpiToolbar, resourceIdentifiers

clauses
    create(Parent) :-
        StatusBar = statusBar::newApplicationWindow(),
        StatusCell = statusBarCell::new(StatusBar, 0),
        StatusBar:cells := [StatusCell],
        Toolbar = vpiToolbar::create(style, Parent, controlList),
        setStatusHandler(Toolbar, { (Text) :- StatusCell:text := Text }).

% This code is maintained automatically, do not update it manually.
%  10:28:12-27.3.2020

constants
    style : vpiToolbar::style = tb_top.
    controlList : vpiToolbar::control_list =
        [
            tb_ctrl(id_file_exit, pushb, resId(idb_exitapp), "Exit application;Exit application", 1, 1),
            vpiToolbar::separator,
            tb_ctrl(id_game_play_3, pushb, resId(idb_game3), "Game 3;Game 3", 1, 1),
            tb_ctrl(id_game_play_5, pushb, resId(idb_game5), "Game 5;Game 5", 1, 1),
            tb_ctrl(id_game_play_7, pushb, resId(idb_game7), "Game 7;Game 7", 1, 1),
            tb_ctrl(id_game_play_n, pushb, resId(idb_gamen), "Game N;Game N", 1, 1),
            vpiToolbar::separator,
            tb_ctrl(id_help_about, pushb, resId(idb_HelpBitmap), "Help;Help", 1, 1)
        ].
% end of automatic code

end implement projectToolbar
