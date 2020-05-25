% Harrison Pratt 2020

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
%  09:03:25-16.5.2020
constants
    style : vpiToolbar::style = tb_top.
    controlList : vpiToolbar::control_list =
        [
            tb_ctrl(id_file_exit, pushb, resId(idb_ExitApplication32), "Exit;Exit application", 1, 1),
            vpiToolbar::separator,
            tb_ctrl(idt_5, pushb, resId(idb_blank_Medium), "", 0, 1),
            tb_ctrl(id_game_open_game_window, pushb, resId(idb_NewGame32), "Open the game window;Open the game window", 1, 1),
            tb_ctrl(idt_6, pushb, resId(idb_blank_Medium), "", 0, 1),
            tb_ctrl(id_game_show_how_to_play, pushb, resId(idb_HowToPlay32), "Show how to play;Show how to play this game in the Messages window", 1,
                1),
            tb_ctrl(idt_7, pushb, resId(idb_blank_Medium), "", 0, 1),
            tb_ctrl(id_game_show_game_rules, pushb, resId(idb_Rules32), "Display game rules;Display game rules in Messages window", 1, 1)
        ].
% end of automatic code

end implement projectToolbar
