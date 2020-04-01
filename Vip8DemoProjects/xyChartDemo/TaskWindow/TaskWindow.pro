% Copyright 2017 Harrison Pratt

implement taskWindow inherits applicationWindow
    open core, vpiDomains

constants
    mdiProperty : boolean = true.

clauses
    new() :-
        applicationWindow::new(),
        generatedInitialize().

class facts
    msgCtrl_fact : messageControl := erroneous.

predicates
    onShow : window::showListener.
clauses
    onShow(_, _CreationData) :-

        % HOWTO Setup Messages window size and font on startup
        MessageFORM = messageForm::display(This),
        MessageFORM:setVerticalSize(messageForm::parentRelative(1.0)), % 1.0 ==> about 100% of parent (client) window
        MessageCTRL = MessageFORM:getMessageControl(),
        MessageCTRL:setFont(vpi::fontCreateByName("Andale Mono", 12)),
        MessageCTRL:setLines(3000),

        msgCtrl_fact := MessageCTRL, % HOWTO If you want to modify the Messages Window it's helpful to store it on startup

        %-- DISPLAY STARTUP INFORMATION in Messages windows

        % HOWTO get a big textual string -- see helpMessages.i
        stdio::write("\n", stringConstants::startupMsg).

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

predicates
    onChartDrawFromApplication : window::menuItemListener.
clauses
    onChartDrawFromApplication(Source, _MenuTag) :-
        % HOWTO draw a chart from application data

        appData_to_Chart::putSomeDataInChart(),
        _ = demoForm::display(Source, "Data from Application").

predicates
    onChartDrawFromFile : window::menuItemListener.
clauses
    onChartDrawFromFile(Source, _MenuTag) :-
        % HOWTO draw a chart from file data

        DemoFileName = "xyDataFile.tsv", % for this demo, the file is in the application directory and does not need path specification
        CsvMask = "*.csv;*.tab;*.tsv",
        Filters = ["CSV files", CsvMask, "ALL files", "*.*"],
        Title = "Select file of data to chart",
        Flags = [],
        mainExe::getFilename(Path, _),
        if QFN = vpiCommonDialogs::getFilename(DemoFileName, Filters, Title, Flags, Path, _SelectedFiles) then
            chartIO::readFileDataXY(QFN), % The data is read into the chart class, where it persists to be read by the demoForm.
            _ = demoForm::display(Source, "Data from File")
        end if.

predicates
    onChartShowDrawingAttrributes : window::menuItemListener.
clauses
    onChartShowDrawingAttrributes(Source, _MenuTag) :-
        % HOWTO display the drawing pen and brush attributes defined in chartDecoration class

        _ = chartDecorationDisplay::display(Source).

predicates
    onChartEditDataFileWithNotepad : window::menuItemListener.
clauses
    onChartEditDataFileWithNotepad(_Source, _MenuTag) :-
        % HOWTO edit data file with Notepad

        QFN = @"xyDataFile.tsv", % for this demo, the file is in the application directory and path specification is not needed
        chartDataEditor::editChartDataWithNotepad(QFN).

predicates
    onFileExploreApplicationDirectory : window::menuItemListener.
clauses
    onFileExploreApplicationDirectory(_Source, _MenuTag) :-
        % HOWTO explore application directory

        mainExe::getFileName(AppDir, _),
        shell_api::shellExecute(nullWindow, "open", "explorer.exe", AppDir).

predicates
    onTestShowDecodersAndEncoders : window::menuItemListener.
clauses
    onTestShowDecodersAndEncoders(_Source, _MenuTag) :-
        % HOWTO display the graphic file encoders and decoders - this is only for reference and testing

        gdipTools::showCodecEncodersAndDecoders().

predicates
    onHelpLocal : window::menuItemListener.
clauses
    onHelpLocal(_Source, _MenuTag) :-
        % HOWTO show a text message in the Messages window

        msgCtrl_fact:clearAll(), % access the message control the application stored on startup (onShow)
        stdio::write("\n", stringConstants::startupMsg).  % retrieve the string to be displayed as a constant in helpMessages.i

predicates
    onHelpDataFileStructure : window::menuItemListener.
clauses
    onHelpDataFileStructure(_Source, _MenuTag) :-

        msgCtrl_fact:clearAll(),
        stdio::write("\n", stringConstants::dataFileFormatMsg).

predicates
    onHelpHowToUseThisCode : window::menuItemListener.
clauses
    onHelpHowToUseThisCode(_Source, _MenuTag) :-

        msgCtrl_fact:clearAll(),
        stdio::write("\n", stringConstants::howToUseChartPackMsg).

% This code is maintained automatically, do not update it manually.
%  07:57:00-9.11.2018

predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setText("xyChartDemo"),
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
        addMenuItemListener(resourceIdentifiers::id_chart_draw_from_application, onChartDrawFromApplication),
        addMenuItemListener(resourceIdentifiers::id_chart_draw_from_file, onChartDrawFromFile),
        addMenuItemListener(resourceIdentifiers::id_chart_show_drawing_attrributes, onChartShowDrawingAttrributes),
        addMenuItemListener(resourceIdentifiers::id_chart_edit_data_file_with_notepad, onChartEditDataFileWithNotepad),
        addMenuItemListener(resourceIdentifiers::id_file_explore_application_directory, onFileExploreApplicationDirectory),
        addMenuItemListener(resourceIdentifiers::id_test_show_decoders_and_encoders, onTestShowDecodersAndEncoders),
        addMenuItemListener(resourceIdentifiers::id_help_local, onHelpLocal),
        addMenuItemListener(resourceIdentifiers::id_help_data_file_structure, onHelpDataFileStructure),
        addMenuItemListener(resourceIdentifiers::id_help_how_to_use_this_code, onHelpHowToUseThisCode).
% end of automatic code

end implement taskWindow
