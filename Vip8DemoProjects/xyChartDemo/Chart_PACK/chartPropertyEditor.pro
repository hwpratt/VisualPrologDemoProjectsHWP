% Copyright 2017 Harrison Pratt

implement chartPropertyEditor inherits dialog

    open core, vpiDomains, string, vpiCommonDialogs, mainExe

class facts
    currChart : chart := erroneous.

clauses
    display(Parent, Chart) = Dialog :-
        currChart := Chart,
        Dialog = new(Parent, Chart),
        Dialog:show().

clauses
    new(Parent, Chart) :-
        dialog::new(Parent),
        generatedInitialize(),
        %----- HP code below -----
        mapChartToDialog(Chart).

class predicates
    editToReal : (string) -> real. % invalid strings convert to 0.0
clauses
    editToReal(S) = R :-
        if R = tryToTerm(real, S) then
        else
            R = 0.0
        end if.

class predicates
    editToInteger : (string) -> integer. % invalid strings convert to 0
clauses
    editToInteger(S) = I :-
        if I = tryToTerm(integer, S) then
        else
            I = 0
        end if.

/******************************************************************************
    CHART PROPERTY MANAGEMENT
		Modify display of CHART, e.g. scaling, grid lines, labels, etc.
******************************************************************************/

predicates
    mapChartToDialog : (chart).
clauses
    mapChartToDialog(C) :-

        edit_ctl_XGridMAJOR:setText(toString(C:gridStepMajorX)),
        edit_ctl_XGridMINOR:setText(toString(C:gridStepMinorX)),
        edit_ctl_YGridMAJOR:setText(toString(C:gridStepMajorY)),
        edit_ctl_YGridMINOR:setText(toString(C:gridStepMinorY)),

        edit_ctl_XMIN:setText(toString(C:valueMinX)),
        edit_ctl_XMAX:setText(toString(C:valueMaxX)),
        edit_ctl_YMIN:setText(toString(C:valueMinY)),
        edit_ctl_YMAX:setText(toString(C:valueMaxY)),

        edit_ctl_XDECIMALS:setText(toString(C:axisDecimalsX)),
        edit_ctl_YDECIMALS:setText(toString(C:axisDecimalsY)),

        edit_ctl_TITLE:setText(C:labelTitle),
        edit_ctl_LABEL_X:setText(C:labelBottom),
        edit_ctl_LABEL_YL:setText(C:labelLeft),
        edit_ctl_LABEL_YR:setText(C:labelRight),

        checkBox_ctl_CONNECTPOINTS:setChecked(C:doConnectPoints).

predicates
    mapDialogToChart : (chart).
    % Reads values from controls and updates Chart properties.
clauses
    mapDialogToChart(C) :-

        C:setDataDisplayRangesXY(editToReal(edit_ctl_XMIN:getText()), editToReal(edit_ctl_XMAX:getText()), editToReal(edit_ctl_YMIN:getText()),
            editToReal(edit_ctl_YMAX:getText())), % NOTE: setDataDisplayRangesXY/4 recalculates X & Y range properties, you don't need to do this separately.

        C:gridStepMajorX := editToReal(edit_ctl_XGridMAJOR:getText()),
        C:gridStepMinorX := editToReal(edit_ctl_XGridMINOR:getText()),
        C:gridStepMajorY := editToReal(edit_ctl_YGridMAJOR:getText()),
        C:gridStepMinorY := editToReal(edit_ctl_YGridMINOR:getText()),

        C:axisDecimalsX := editToInteger(edit_ctl_XDECIMALS:getText()),
        C:axisDecimalsY := editToInteger(edit_ctl_YDECIMALS:getText()),

        C:labelTitle := edit_ctl_TITLE:getText(),
        C:labelBottom := edit_ctl_LABEL_X:getText(),
        C:labelLeft := edit_ctl_LABEL_YL:getText(),
        C:labelRight := edit_ctl_LABEL_YR:getText(),
        C:doConnectPoints := checkBox_ctl_CONNECTPOINTS:getChecked().

/******************************************************************************
    PROPERTY FILE MANAGEMENT
        Saves/recalls only the current chart's display properties.
        Use of named property files may be added later.
******************************************************************************/
%constants
%    propertyFileName = "ChartDisplayParms.ini".

predicates
    readPropertiesFromFile : (string FName).
clauses
    readPropertiesFromFile(FName) :-
        if file::existExactFile(FName) then
            FileStr = file::readString(FName),
            KvLIST = split(FileStr, "\n"),
            mapKvLISTToDIALOG(KvLIST)
        else
            vpiCommonDialogs::error(concat("ERROR in ", predicate_fullname()), format("File '%' does not exist.", FName))
        end if.

predicates
    writePropertiesToFile : (string FName).
clauses
    writePropertiesToFile(FName) :-
        OS = outputStream_file::create8(Fname),
        KvLIST = mapDialogToKvLIST(),
        foreach S = list::getMember_nd(KvLIST) do
            OS:write(S),
            OS:nl
        end foreach,
        OS:close().

predicates
    getPropertyFileName : (string TitlePrefix) -> string PropertyFileName_INI determ.
clauses
    getPropertyFileName(TitlePrefix) = PropertyFileName_INI :-
        Filters = ["INI files", "*.ini", "All files", "*.*"],
        Title = concat(TitlePrefix, " Chart Property File (*.ini)"),
        Flags = [],
        mainExe::getFilename(Path, _),
        PropertyFileName_INI = vpiCommonDialogs::getFilename("*.ini", Filters, Title, Flags, Path, _SelectedFiles).

predicates
    mapDialogToKvLIST : () -> string_list PropertyKeyValueList.
clauses
    mapDialogToKvLIST() = ParmList :-
        XGridMAJOR = concat("GridMajorX=", edit_ctl_XGridMAJOR:getText()),
        XGridMINOR = concat("GridMinorX=", edit_ctl_XGridMINOR:getText()),
        YGridMAJOR = concat("GridMajorY=", edit_ctl_YGridMAJOR:getText()),
        YGridMINOR = concat("GridMinorY=", edit_ctl_YGridMAJOR:getText()),
        XMIN = concat("MinX=", edit_ctl_XMIN:getText()),
        XMAX = concat("MaxX=", edit_ctl_XMAX:getText()),
        YMIN = concat("MinY=", edit_ctl_YMIN:getText()),
        YMAX = concat("MaxY=", edit_ctl_YMIN:getText()),
        XDECIMALS = concat("DecimalsX=", edit_ctl_XDECIMALS:getText()),
        YDECIMALS = concat("DecimalsY=", edit_ctl_YDECIMALS:getText()),
        TITLE = concat("LabelTitle=", edit_ctl_TITLE:getText()),
        LABEL_X = concat("LabelX=", edit_ctl_LABEL_X:getText()),
        LABEL_YL = concat("LabelYL=", edit_ctl_LABEL_YL:getText()),
        LABEL_YR = concat("LabelYR=", edit_ctl_LABEL_YR:getText()),
        CONNECTPOINTS = concat("ConnectPointsTF=", toString(checkBox_ctl_CONNECTPOINTS:getChecked())),
        ParmList =
            [
                XGridMAJOR,
                XGridMINOR,
                YGridMAJOR,
                YGridMINOR,
                XMIN,
                XMAX,
                YMIN,
                YMAX,
                XDECIMALS,
                YDECIMALS,
                TITLE,
                LABEL_X,
                LABEL_YL,
                LABEL_YR,
                CONNECTPOINTS
            ].

predicates
    mapKvLISTToDIALOG : (string_list PropertyKeyValueList).
clauses
    mapKvLISTToDIALOG(KvLIST) :-
        %-- update the edit_ctls
        foreach S = list::getMember_nd(KvLIST) and [K, V] = string::split(S, "=") and EditCtrl = key_editControl(K) do
            EditCtrl:setText(V)
        end foreach,
        %-- update the checkBox_ctl
        foreach S = list::getMember_nd(KvLIST) and [K, V] = string::split(S, "=") and K = "ConnectPointsTF" do
            checkBox_ctl_CONNECTPOINTS:setChecked(toBoolean(V = "true"))
        end foreach,
        succeed.

predicates
    key_editControl : (string KeyString) -> editControl ResID determ.
    % lookup edit control ID using property key string to simplify mapping
    % checkBox control is managed with different program logic
clauses
    key_editControl("GridMajorX") = edit_ctl_XGridMAJOR :-
        !.
    key_editControl("GridMinorX") = edit_ctl_XGridMINOR :-
        !.
    key_editControl("GridMajorY") = edit_ctl_YGridMAJOR :-
        !.
    key_editControl("GridMinorY") = edit_ctl_YGridMAJOR :-
        !.
    key_editControl("MinX") = edit_ctl_XMIN :-
        !.
    key_editControl("MaxX") = edit_ctl_XMAX :-
        !.
    key_editControl("MinY") = edit_ctl_YMIN :-
        !.
    key_editControl("MaxY") = edit_ctl_YMIN :-
        !.
    key_editControl("DecimalsX") = edit_ctl_XDECIMALS :-
        !.
    key_editControl("DecimalsY") = edit_ctl_YDECIMALS :-
        !.
    key_editControl("LabelTitle") = edit_ctl_TITLE :-
        !.
    key_editControl("LabelX") = edit_ctl_LABEL_X :-
        !.
    key_editControl("LabelYL") = edit_ctl_LABEL_YL :-
        !.
    key_editControl("LabelYR") = edit_ctl_LABEL_YR :-
        !.

predicates
    onOkClick : button::clickResponder.
clauses
    onOkClick(_Source) = button::defaultAction :-

        mapDialogToChart(currChart).

predicates
    onPushButton_ctl_SAVEPARMSClick : button::clickResponder.
clauses
    onPushButton_ctl_SAVEPARMSClick(_Source) = button::defaultAction :-

        if getPropertyFileName("Save") = QFN then
            writePropertiesToFile(QFN)
        end if.

predicates
    onPushButton_ctl_RECALLClick : button::clickResponder.
clauses
    onPushButton_ctl_RECALLClick(_Source) = button::defaultAction :-

        if getPropertyFileName("Recall") = QFN then
            readPropertiesFromFile(QFN)
        end if.

% This code is maintained automatically, do not update it manually.
%  12:59:08-26.7.2017

facts
    ok_ctl : button.
    cancel_ctl : button.
    help_ctl : button.
    edit_ctl_XMIN : editControl.
    edit_ctl_XMAX : editControl.
    edit_ctl_YMIN : editControl.
    edit_ctl_YMAX : editControl.
    edit_ctl_XGridMAJOR : editControl.
    edit_ctl_XGridMINOR : editControl.
    edit_ctl_YGridMAJOR : editControl.
    edit_ctl_YGridMINOR : editControl.
    edit_ctl_XDECIMALS : editControl.
    edit_ctl_YDECIMALS : editControl.
    edit_ctl_TITLE : editControl.
    edit_ctl_LABEL_X : editControl.
    edit_ctl_LABEL_YL : editControl.
    edit_ctl_LABEL_YR : editControl.
    checkBox_ctl_CONNECTPOINTS : checkButton.
    pushButton_ctl_RECALL : button.
    pushButton_ctl_SAVEPARMS : button.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setFont(vpi::fontCreateByName("Tahoma", 10)),
        setText("chartPropertyEditor"),
        setRect(rct(5, 15, 245, 345)),
        setModal(true),
        setDecoration(titlebar([closeButton])),
        setState([wsf_NoClipSiblings]),
        ok_ctl := button::newOk(This),
        ok_ctl:setText("&OK"),
        ok_ctl:setPosition(44, 308),
        ok_ctl:setSize(56, 16),
        ok_ctl:defaultHeight := false,
        ok_ctl:setAnchors([control::right, control::bottom]),
        ok_ctl:setClickResponder(onOkClick),
        cancel_ctl := button::newCancel(This),
        cancel_ctl:setText("Cancel"),
        cancel_ctl:setPosition(108, 308),
        cancel_ctl:setSize(56, 16),
        cancel_ctl:defaultHeight := false,
        cancel_ctl:setAnchors([control::right, control::bottom]),
        help_ctl := button::new(This),
        help_ctl:setText("&Help"),
        help_ctl:setPosition(172, 308),
        help_ctl:setWidth(56),
        help_ctl:defaultHeight := true,
        help_ctl:setAnchors([control::right, control::bottom]),
        help_ctl:setEnabled(false),
        edit_ctl_XMIN := editControl::new(This),
        edit_ctl_XMIN:setText(""),
        edit_ctl_XMIN:setPosition(72, 34),
        edit_ctl_XMIN:setWidth(36),
        edit_ctl_XMAX := editControl::new(This),
        edit_ctl_XMAX:setText(""),
        edit_ctl_XMAX:setPosition(124, 34),
        edit_ctl_XMAX:setWidth(36),
        edit_ctl_YMIN := editControl::new(This),
        edit_ctl_YMIN:setText(""),
        edit_ctl_YMIN:setPosition(72, 48),
        edit_ctl_YMIN:setWidth(36),
        edit_ctl_YMIN:setHeight(12),
        edit_ctl_YMIN:setMultiLine(),
        edit_ctl_YMAX := editControl::new(This),
        edit_ctl_YMAX:setText(""),
        edit_ctl_YMAX:setPosition(124, 48),
        edit_ctl_YMAX:setWidth(36),
        edit_ctl_YMAX:setHeight(12),
        edit_ctl_YMAX:setMultiLine(),
        StaticText_ctl_MIN = textControl::new(This),
        StaticText_ctl_MIN:setText("Minimum"),
        StaticText_ctl_MIN:setPosition(72, 18),
        StaticText_ctl_MIN:setSize(36, 14),
        StaticText_ctl_MAX = textControl::new(This),
        StaticText_ctl_MAX:setText("Maximum"),
        StaticText_ctl_MAX:setPosition(124, 18),
        StaticText_ctl_MAX:setSize(36, 14),
        StaticText_ctl_X = textControl::new(This),
        StaticText_ctl_X:setText("X:"),
        StaticText_ctl_X:setPosition(32, 34),
        StaticText_ctl_X:setSize(36, 12),
        StaticText_ctl_X:setAlignment(alignRight),
        StaticText_ctl_Y = textControl::new(This),
        StaticText_ctl_Y:setText("Y:"),
        StaticText_ctl_Y:setPosition(32, 48),
        StaticText_ctl_Y:setSize(36, 12),
        StaticText_ctl_Y:setAlignment(alignRight),
        GroupBox_ctl = groupBox::new(This),
        GroupBox_ctl:setText("Grid Drawing Intervals"),
        GroupBox_ctl:setPosition(12, 68),
        GroupBox_ctl:setSize(216, 8),
        GroupBox_ctl:setBorderStyle(groupbox::horizontalSeparator()),
        GroupBox1_ctl = groupBox::new(This),
        GroupBox1_ctl:setText("X & Y Display Ranges"),
        GroupBox1_ctl:setPosition(12, 4),
        GroupBox1_ctl:setSize(216, 10),
        GroupBox1_ctl:setBorderStyle(groupbox::horizontalSeparator()),
        StaticText_ctl_MAJOR = textControl::new(This),
        StaticText_ctl_MAJOR:setText("Major"),
        StaticText_ctl_MAJOR:setPosition(72, 80),
        StaticText_ctl_MAJOR:setSize(36, 12),
        StaticText_ctl_MINOR = textControl::new(This),
        StaticText_ctl_MINOR:setText("Minor"),
        StaticText_ctl_MINOR:setPosition(124, 80),
        StaticText_ctl_MINOR:setSize(36, 12),
        StaticText_ctl_XGRID = textControl::new(This),
        StaticText_ctl_XGRID:setText("X-Grid:"),
        StaticText_ctl_XGRID:setPosition(20, 94),
        StaticText_ctl_XGRID:setSize(48, 12),
        StaticText_ctl_XGRID:setAlignment(alignRight),
        StaticText_ctl_YGRID = textControl::new(This),
        StaticText_ctl_YGRID:setText("Y-Grid:"),
        StaticText_ctl_YGRID:setPosition(20, 108),
        StaticText_ctl_YGRID:setSize(48, 12),
        StaticText_ctl_YGRID:setAlignment(alignRight),
        edit_ctl_XGridMAJOR := editControl::new(This),
        edit_ctl_XGridMAJOR:setText(""),
        edit_ctl_XGridMAJOR:setPosition(72, 94),
        edit_ctl_XGridMAJOR:setWidth(36),
        edit_ctl_XGridMAJOR:setHeight(12),
        edit_ctl_XGridMAJOR:setMultiLine(),
        edit_ctl_XGridMINOR := editControl::new(This),
        edit_ctl_XGridMINOR:setText(""),
        edit_ctl_XGridMINOR:setPosition(124, 94),
        edit_ctl_XGridMINOR:setWidth(36),
        edit_ctl_XGridMINOR:setHeight(12),
        edit_ctl_XGridMINOR:setMultiLine(),
        edit_ctl_YGridMAJOR := editControl::new(This),
        edit_ctl_YGridMAJOR:setText(""),
        edit_ctl_YGridMAJOR:setPosition(72, 108),
        edit_ctl_YGridMAJOR:setWidth(36),
        edit_ctl_YGridMAJOR:setHeight(12),
        edit_ctl_YGridMAJOR:setMultiLine(),
        edit_ctl_YGridMINOR := editControl::new(This),
        edit_ctl_YGridMINOR:setText(""),
        edit_ctl_YGridMINOR:setPosition(124, 108),
        edit_ctl_YGridMINOR:setWidth(36),
        edit_ctl_YGridMINOR:setHeight(12),
        edit_ctl_YGridMINOR:setMultiLine(),
        GroupBox2_ctl = groupBox::new(This),
        GroupBox2_ctl:setText("Axis Value Decimal Places"),
        GroupBox2_ctl:setPosition(12, 126),
        GroupBox2_ctl:setSize(216, 8),
        GroupBox2_ctl:setBorderStyle(groupbox::horizontalSeparator()),
        StaticText_ctl_XDecimals = textControl::new(This),
        StaticText_ctl_XDecimals:setText("X Decimals:"),
        StaticText_ctl_XDecimals:setPosition(20, 138),
        StaticText_ctl_XDecimals:setSize(48, 12),
        StaticText_ctl_XDecimals:setAlignment(alignRight),
        StaticText_ctl_YDecimals = textControl::new(This),
        StaticText_ctl_YDecimals:setText("Y Decimals:"),
        StaticText_ctl_YDecimals:setPosition(20, 152),
        StaticText_ctl_YDecimals:setSize(48, 12),
        StaticText_ctl_YDecimals:setAlignment(alignRight),
        edit_ctl_XDECIMALS := editControl::new(This),
        edit_ctl_XDECIMALS:setText(""),
        edit_ctl_XDECIMALS:setPosition(72, 138),
        edit_ctl_XDECIMALS:setWidth(36),
        edit_ctl_XDECIMALS:setHeight(12),
        edit_ctl_XDECIMALS:setMultiLine(),
        edit_ctl_YDECIMALS := editControl::new(This),
        edit_ctl_YDECIMALS:setText(""),
        edit_ctl_YDECIMALS:setPosition(72, 152),
        edit_ctl_YDECIMALS:setWidth(36),
        edit_ctl_YDECIMALS:setHeight(12),
        edit_ctl_YDECIMALS:setMultiLine(),
        GroupBox3_ctl = groupBox::new(This),
        GroupBox3_ctl:setText("Title and Axis Labels"),
        GroupBox3_ctl:setPosition(12, 170),
        GroupBox3_ctl:setSize(216, 8),
        GroupBox3_ctl:setBorderStyle(groupbox::horizontalSeparator()),
        StaticText_ctl = textControl::new(This),
        StaticText_ctl:setText("Chart Title:"),
        StaticText_ctl:setPosition(20, 182),
        StaticText_ctl:setSize(56, 12),
        StaticText_ctl:setAlignment(alignRight),
        StaticText1_ctl = textControl::new(This),
        StaticText1_ctl:setText("X-Label:"),
        StaticText1_ctl:setPosition(20, 196),
        StaticText1_ctl:setSize(56, 12),
        StaticText1_ctl:setAlignment(alignRight),
        StaticText2_ctl = textControl::new(This),
        StaticText2_ctl:setText("Y-Label LEFT:"),
        StaticText2_ctl:setPosition(20, 210),
        StaticText2_ctl:setSize(56, 12),
        StaticText2_ctl:setAlignment(alignRight),
        StaticText3_ctl = textControl::new(This),
        StaticText3_ctl:setText("Y-Label RIGHT:"),
        StaticText3_ctl:setPosition(20, 224),
        StaticText3_ctl:setSize(56, 12),
        StaticText3_ctl:setAlignment(alignRight),
        edit_ctl_TITLE := editControl::new(This),
        edit_ctl_TITLE:setText(""),
        edit_ctl_TITLE:setPosition(80, 182),
        edit_ctl_TITLE:setWidth(148),
        edit_ctl_TITLE:setHeight(12),
        edit_ctl_TITLE:setMultiLine(),
        edit_ctl_LABEL_X := editControl::new(This),
        edit_ctl_LABEL_X:setText(""),
        edit_ctl_LABEL_X:setPosition(80, 196),
        edit_ctl_LABEL_X:setWidth(148),
        edit_ctl_LABEL_X:setHeight(12),
        edit_ctl_LABEL_X:setMultiLine(),
        edit_ctl_LABEL_YL := editControl::new(This),
        edit_ctl_LABEL_YL:setText(""),
        edit_ctl_LABEL_YL:setPosition(80, 210),
        edit_ctl_LABEL_YL:setWidth(148),
        edit_ctl_LABEL_YL:setHeight(12),
        edit_ctl_LABEL_YL:setMultiLine(),
        edit_ctl_LABEL_YR := editControl::new(This),
        edit_ctl_LABEL_YR:setText(""),
        edit_ctl_LABEL_YR:setPosition(80, 224),
        edit_ctl_LABEL_YR:setWidth(148),
        edit_ctl_LABEL_YR:setHeight(12),
        edit_ctl_LABEL_YR:setMultiLine(),
        GroupBox4_ctl = groupBox::new(This),
        GroupBox4_ctl:setText("Other Plotting Options"),
        GroupBox4_ctl:setPosition(12, 242),
        GroupBox4_ctl:setSize(216, 8),
        GroupBox4_ctl:setBorderStyle(groupbox::horizontalSeparator()),
        checkBox_ctl_CONNECTPOINTS := checkButton::new(This),
        checkBox_ctl_CONNECTPOINTS:setText("Connect Points"),
        checkBox_ctl_CONNECTPOINTS:setPosition(20, 256),
        checkBox_ctl_CONNECTPOINTS:setWidth(100),
        GroupBox5_ctl = groupBox::new(This),
        GroupBox5_ctl:setText("Save and Recall Properties"),
        GroupBox5_ctl:setPosition(12, 272),
        GroupBox5_ctl:setSize(216, 26),
        pushButton_ctl_RECALL := button::new(GroupBox5_ctl),
        pushButton_ctl_RECALL:setText("&Recall"),
        pushButton_ctl_RECALL:setPosition(163, 0),
        pushButton_ctl_RECALL:setSize(44, 12),
        pushButton_ctl_RECALL:defaultHeight := false,
        pushButton_ctl_RECALL:setClickResponder(onPushButton_ctl_RECALLClick),
        pushButton_ctl_SAVEPARMS := button::new(GroupBox5_ctl),
        pushButton_ctl_SAVEPARMS:setText("&Save"),
        pushButton_ctl_SAVEPARMS:setPosition(111, 0),
        pushButton_ctl_SAVEPARMS:setSize(44, 12),
        pushButton_ctl_SAVEPARMS:defaultHeight := false,
        pushButton_ctl_SAVEPARMS:setClickResponder(onPushButton_ctl_SAVEPARMSClick).
% end of automatic code

end implement chartPropertyEditor
