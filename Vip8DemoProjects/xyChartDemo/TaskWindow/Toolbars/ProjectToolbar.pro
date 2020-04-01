% Copyright 2017 Harrison Pratt

implement projectToolbar
    open core, vpiDomains, vpiToolbar, resourceIdentifiers

clauses
    create(Parent) :-
        StatusBar = statusBar::newApplicationWindow(),
        StatusCell = statusBarCell::new(StatusBar, 0),
        StatusBar:cells := [StatusCell],
        Toolbar = vpiToolbar::create(style, Parent, controlList),
        setStatusHandler(Toolbar, {(Text) :- StatusCell:text := Text}).

% This code is maintained automatically, do not update it manually.
%  10:31:47-8.11.2018

constants
    style : vpiToolbar::style = tb_top.
    controlList : vpiToolbar::control_list =
        [
            tb_ctrl(id_file_new, pushb, resId(idb_NewFileBitmap), "New;New File", 0, 1),
            tb_ctrl(id_file_explore_application_directory, pushb, resId(idb_OpenFileBitmap),
                "Explore;Open application directory with Windows File Explorer", 1, 1),
            tb_ctrl(id_file_save, pushb, resId(idb_SaveFileBitmap), "Save;Save File", 0, 1),
            vpiToolbar::separator,
            tb_ctrl(id_edit_undo, pushb, resId(idb_UndoBitmap), "Undo;Undo", 0, 1),
            tb_ctrl(id_edit_redo, pushb, resId(idb_RedoBitmap), "Redo;Redo", 0, 1),
            vpiToolbar::separator,
            tb_ctrl(id_edit_cut, pushb, resId(idb_CutBitmap), "Cut;Cut to Clipboard", 0, 1),
            tb_ctrl(id_edit_copy, pushb, resId(idb_CopyBitmap), "Copy;Copy to Clipboard", 0, 1),
            tb_ctrl(id_edit_paste, pushb, resId(idb_PasteBitmap), "Paste;Paste from Clipboard", 0, 1),
            vpiToolbar::separator,
            tb_ctrl(id_help_local, pushb, resId(idb_HelpBitmap), "Help;Help", 1, 1)
        ].
% end of automatic code
end implement projectToolbar