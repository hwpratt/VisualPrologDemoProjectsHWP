/******************************************************************************
Author:         Harrison Pratt      Copyright(c) 2020 Quixote Software
File:           askGameSize.cl
Project:        TicTacToeN
Package:        pack_GAME
Keywords:       
Created:        2020-03-29
Modified:       
Purpose:        Ask the user for an integral game size.
                Size is the X & Y dimension, and must be >= 3.
Comments:       FAILS on [Cancel] pressed.
Examples:       
******************************************************************************/
implement askGameSize inherits dialog
    open core, vpiDomains

class facts - dlgDataDB
    returnValue : integer := erroneous.

clauses
    display(Parent) = returnValue :-
        Dialog = new(Parent),
        Dialog:show(),
        %-----
        not(isErroneous(returnValue)).  % HOWTO fail if [OK] was not clicked or no valid number was entered. See onOkClick/1 below

clauses
    new(Parent) :-
        dialog::new(Parent),
        generatedInitialize().

predicates
    onShow : window::showListener.
clauses
    onShow(_Source, _Data) :-
        centerTo(applicationSession::getSessionWindow()), % HOWTO center dialog in application window
        integerControl_ctl:setFocus().  % HOWTO move cursor to integer control when the dialog opens

predicates
    onOkClick : button::clickResponder.
clauses
    onOkClick(_Source) = Action :-
        % HOWTO handle invalid (i.e. non-digit) characters in this dialog's integerControl
        try
            returnValue := integerControl_ctl:getInteger(), % returned a valid integer, so store it in the fact 'returnValue'
            Action = button::defaultAction
        catch _ do
            % An invalid character in integerControl caused exception
            % Note that 'returnValue' remains 'erroneous'
            Action = button::noAction
        end try.

predicates
    onCancelClick : button::clickResponder.
clauses
    onCancelClick(_Source) = button::defaultAction :-
        % HOWTO exit the dialog on [Cancel].
        % Note that the returnValue fact remains erroneous
        % when it is handled in the display/2 clause
        % but onOkClick/1 sets returnValue to the board size
        destroy().

% This code is maintained automatically, do not update it manually.
%  11:14:55-27.3.2020
facts
    ok_ctl : button.
    cancel_ctl : button.
    integerControl_ctl : integercontrol.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setText("Create a new game with custom size"),
        setRect(rct(50, 40, 233, 96)),
        setModal(true),
        setDecoration(titlebar([closeButton])),
        setState([wsf_NoClipSiblings]),
        addShowListener(onShow),
        ok_ctl := button::newOk(This),
        ok_ctl:setText("&OK"),
        ok_ctl:setPosition(52, 33),
        ok_ctl:setSize(56, 16),
        ok_ctl:defaultHeight := false,
        ok_ctl:setAnchors([control::right, control::bottom]),
        ok_ctl:setClickResponder(onOkClick),
        cancel_ctl := button::newCancel(This),
        cancel_ctl:setText("Cancel"),
        cancel_ctl:setPosition(116, 33),
        cancel_ctl:setSize(56, 16),
        cancel_ctl:defaultHeight := false,
        cancel_ctl:setAnchors([control::right, control::bottom]),
        cancel_ctl:setClickResponder(onCancelClick),
        StaticText_ctl_prompt = textControl::new(This),
        StaticText_ctl_prompt:setText("Enter the number of cells across for your TicTacToe game"),
        StaticText_ctl_prompt:setPosition(32, 8),
        StaticText_ctl_prompt:setSize(108, 16),
        StaticText_ctl_prompt:setAlignment(alignRight),
        integerControl_ctl := integercontrol::new(This),
        integerControl_ctl:setPosition(148, 8),
        integerControl_ctl:setWidth(24),
        integerControl_ctl:setAutoHScroll(false),
        integerControl_ctl:setText("3"),
        integerControl_ctl:setAlignBaseline(false),
        integerControl_ctl:setAlignment(alignRight),
        Icon_ctl = iconControl::new(This),
        Icon_ctl:setIcon(resourceIdentifiers::idi_projecticonwhite),
        Icon_ctl:setPosition(12, 8),
        Icon_ctl:setBorder(false).
% end of automatic code

end implement askGameSize
