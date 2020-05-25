% Harrison Pratt 2020

implement selectStandardPattern inherits dialog
    open core, vpiDomains

class facts
    responseList : integer_list_list := erroneous.
    /* Typical response list structure.  Only 'alive' cells are listed; unlisted cells are 'dead'

    [1,3],  % The first list is always the 0th row/cell. The row has cells 0,1 and 0,3 alive.
    [],     % Row 1 is empty.  Each row must be represented, even if it has no live cells.
    [4,8]   % Row 2 has cells 2,4 and 2,8 alive.
    ...
    etc.
    III = [ CellsRow0, CellsRow1, ... CellsRowN ].  where CellsRowX is an integer_list
    */

clauses
    display(Parent) = responseList :-
        Dialog = new(Parent),
        _ = gameStoreDB::new(),
        Dialog:show(),
        not(isErroneous(responseList)).

clauses
    new(Parent) :-
        dialog::new(Parent),
        generatedInitialize(),
        listbox_ctl_CATEGORY:addList(gameStoreDB::patCategoriesU()),
        listbox_ctl_CATEGORY:setFocus().

predicates
    onOkClick : button::clickResponder.
clauses
    onOkClick(_Source) = Response :-
        if checkBox_ctl:getCheckedState() = checkButton::checked then
            % generate a set of random 'live' cell integer_list_list
            Size = 9, % height & width limits of generated row/cell tuples
            Density = 3, % number of times to generate random tuples in the Size square
            Tuples =
                list::sort(
                    list::removeDuplicates(
                        [ tuple(R, C) ||
                            _ = std::fromTo(0, Size + Density),
                            R = math::random(Size),
                            C = math::random(Size)
                        ])),
            responseList :=
                [ II ||
                    Row = std::fromTo(0, Size),
                    II = [ C || tuple(Row, C) in Tuples ]
                ],
            Response = button::defaultAction
        elseif checkBox_ctl:getCheckedState() <> checkButton::checked and [Cat] = listbox_ctl_CATEGORY:getSelectedItems()
            and [Name] = listbox_ctl_NAME:getSelectedItems() and responseList := gameStoreDB::patCategoryNameCells(Cat, Name)
        then
            Response = button::defaultAction
        else
            Response = button::noAction
        end if.

predicates
    onListbox_ctl_CATEGORYSelectionChanged : listControl::selectionChangedListener.
clauses
    onListbox_ctl_CATEGORYSelectionChanged(_Source) :-
        if [Cat] = listbox_ctl_CATEGORY:getSelectedItems() then
            Names = gameStoreDB::patCategoryNames(Cat),
            listbox_ctl_NAME:clearAll(),
            listbox_ctl_NAME:addList(Names),
            listbox_ctl_NAME:setFocus()
        end if.

predicates
    onShow : window::showListener.
clauses
    onShow(Source, _Data) :-
        centerTo(Source).

predicates
    onCheckBoxStateChanged : checkButton::stateChangedListener.
clauses
    onCheckBoxStateChanged(_Source, _OldState, _NewState) :-
        if checkBox_ctl:getCheckedState() = checkButton::checked then
            CtrlState = vpiDomains::wsf_disabled
        else
            CtrlState = wsf_enabled
        end if,
        foreach Ctrl in [listbox_ctl_CATEGORY, listbox_ctl_NAME, staticText_ctl, staticText1_ctl] do
            Ctrl:setState([CtrlState])
        end foreach.

% This code is maintained automatically, do not update it manually.
%  08:25:31-15.5.2020
facts
    ok_ctl : button.
    cancel_ctl : button.
    listbox_ctl_CATEGORY : listBox.
    staticText_ctl : textControl.
    staticText1_ctl : textControl.
    listbox_ctl_NAME : listBox.
    checkBox_ctl : checkButton.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setText("Select Standard Pattern"),
        setRect(rct(50, 40, 274, 180)),
        setModal(true),
        setDecoration(titlebar([closeButton])),
        setState([wsf_NoClipSiblings]),
        addShowListener(onShow),
        ok_ctl := button::newOk(This),
        ok_ctl:setText("&OK"),
        ok_ctl:setPosition(48, 118),
        ok_ctl:setSize(56, 16),
        ok_ctl:defaultHeight := false,
        ok_ctl:setAnchors([control::right, control::bottom]),
        ok_ctl:setClickResponder(onOkClick),
        cancel_ctl := button::newCancel(This),
        cancel_ctl:setText("Cancel"),
        cancel_ctl:setPosition(116, 118),
        cancel_ctl:setSize(56, 16),
        cancel_ctl:defaultHeight := false,
        cancel_ctl:setAnchors([control::right, control::bottom]),
        listbox_ctl_CATEGORY := listBox::new(This),
        listbox_ctl_CATEGORY:setPosition(12, 17),
        listbox_ctl_CATEGORY:setSize(92, 65),
        listbox_ctl_CATEGORY:addSelectionChangedListener(onListbox_ctl_CATEGORYSelectionChanged),
        staticText_ctl := textControl::new(This),
        staticText_ctl:setText("Category:"),
        staticText_ctl:setPosition(12, 6),
        staticText_ctl:setSize(33, 8),
        staticText1_ctl := textControl::new(This),
        staticText1_ctl:setText("Pattern name:"),
        staticText1_ctl:setPosition(116, 6),
        staticText1_ctl:setSize(47, 8),
        listbox_ctl_NAME := listBox::new(This),
        listbox_ctl_NAME:setPosition(116, 17),
        listbox_ctl_NAME:setSize(92, 65),
        checkBox_ctl := checkButton::new(This),
        checkBox_ctl:setText("Generate a random pattern instead of a category pattern"),
        checkBox_ctl:setPosition(12, 94),
        checkBox_ctl:setWidth(203),
        checkBox_ctl:addStateChangedListener(onCheckBoxStateChanged).
% end of automatic code

end implement selectStandardPattern
