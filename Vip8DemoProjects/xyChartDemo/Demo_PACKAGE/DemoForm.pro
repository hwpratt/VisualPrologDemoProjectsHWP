% Copyright 2017 Harrison Pratt

implement demoForm inherits formWindow

    open core, vpiDomains, vpiCommonDialogs, fileName

class facts % HOWTO add single fact to remember the chartObject you are using

    chartObject : chart := erroneous.

clauses
    display(Parent, TitleText) = Form :-
        Form = new(Parent),
        Form:setText(TitleText),
        Form:show().

    display(Parent) = Form :-
        Form = new(Parent),
        Form:show().

clauses
    new(Parent) :-
        % HOWTO create a new form, remember the chart object and load the data from chartIO

        formWindow::new(Parent),
        generatedInitialize(),
        % -- add the user code below to the form's constructor when building your application
        C = chart::new(class_name()), % class_name() is the name of this form's class; you could use any string literal here, too.
        chartObject := C,
        C:readDataXY_fromIO().

predicates
    onDestroy : window::destroyListener.
clauses
    onDestroy(_Source) :-
        % HOWTO deregister the chart

        chart::deregisterChartNamed(class_name()).

predicates
    onPaint : window::paintResponder.
clauses
    onPaint(SOURCE, _Rectangle, GDI) :-
        % HOWTO handle painting the form.  Note that SOURCE & GDI are not anonymous variables!

        HDC = GDI:getNativeGraphicContext(IsReleaseNeeded),

        Graphics = graphics::createFromHDC(HDC),
        Graphics:smoothingMode := gdiplus_native::smoothingModeAntiAlias, % the default is unsmoothed

        if Chart = chart::getChartNamed(class_name()) then
            Chart:scaleChartToWIndow(SOURCE), % <== this handles all form resizing calculations & MUST be done before drawing
            Chart:drawChartXY(Graphics)
        end if,

        GDI:releaseNativeGraphicContext(HDC, IsReleaseNeeded).

predicates
    onSize : window::sizeListener.
clauses
    onSize(Source) :-
        % HOWTO force chart to redraw after resizing the form

        Source:invalidate().

predicates
    onMouseUp : window::mouseUpListener.
clauses
    onMouseUp(SOURCE, _, _, MOUSEBUTTON) :-
        % HOWTO open chart property editor

        if MOUSEBUTTON = mouse_button_RIGHT and Chart = chart::getChartNamed(class_name()) then
            _ = chartPropertyEditor::display(SOURCE, Chart),
            SOURCE:invalidate()
        end if.

predicates
    onMouseDown : window::mouseDownListener.
clauses
    onMouseDown(SOURCE, PNTVPI, SHIFTCONTROLALT, MOUSEBUTTON) :-
        % HOWTO move legend by changing legendInsetRatio properties

        C = chartObject,

        if MOUSEBUTTON = mouse_button_LEFT and SHIFTCONTROLALT = vpiDomains::c_Control and C:isPointInLegend(PNTVPI) then
            % start of move Legend
            C:legendMoveMode := true
        end if,

        if MOUSEBUTTON = mouse_button_LEFT and SHIFTCONTROLALT = vpiDomains::c_Nothing and C:legendMoveMode = true then
            % finish move Legend
            tuple(IrX, IrY) = C:insetRatio_fromPNT(PntVPI, chartObject),
            C:legendInsetRatioX := IrX,
            C:legendInsetRatioY := IrY,
            C:legendMoveMode := false,
            SOURCE:invalidate()
        end if.

predicates
    onKeyUp : window::keyUpResponder.
clauses
    onKeyUp(Source, Key, ShiftControlAlt) = window::defaultKeyUpHandling :-

        % HOWTO 2018-11-05  Save the graph image to Windows clipboard or file when Alt-C pressed
        Key = vpiDomains::k_C,
        ShiftControlAlt = vpiDomains::c_Alt,
        Options = ["Copy to clipboard", "Save as BMP file", "Save as JPG file", "Save as PNG file"],
        if b_TRUE = vpiCommonDialogs::listSelect("Capture Graph Image", Options, -1, _SelectedStr, SelectedIndex) then

            if SelectedIndex = 0 then
                screenCapture::clientWin_putClipboardBMP(Source)
            elseif SelectedIndex = 1 then
                screenCapture::clientWin_saveAsFile(Source, filename::setExtension(class_name(), "BMP"), "BMP")
            elseif SelectedIndex = 2 then
                %-- Note that the file type encoder for JPG file is "JPEG", not "JPG"
                screenCapture::clientWin_saveAsFile(Source, filename::setExtension(class_name(), "JPG"), "JPEG")
            elseif SelectedIndex = 3 then
                screenCapture::clientWin_saveAsFile(Source, filename::setExtension(class_name(), "PNG"), "PNG")
            else
                vpiCommonDialogs::error(predicate_fullname(), "Should never get here!")
            end if
        else
            succeed()
        end if,

        % HOWTO 2018-11-05  save the form client window as a file
%        Key = vpiDomains::k_C,

%        screenCapture::clientWin_putClipboardBMP( Source ),
%        screenCapture::clientWin_saveAsFile( Source, "test.ico", "ICON" ),

%        BMP = screenCapture::getClientBmp( Source ),
%            sizeof( BMP ) > 0,
%        vpi::cbPutPicture( Pic ),
%        clipboard::putUserDefined( Source, Fmt, Pic ), % hwp see gui_native.cl for clipboard formats (e.g., cf_bitmap, cf_text, etc.)
% also see https://msdn.microsoft.com/en-us/library/windows/desktop/ms649013(v=vs.85).aspx#_win32_Standard_Clipboard_Formats
        succeed,
        !.

    onKeyUp(_, _, _) = window::defaultKeyUpHandling.

% This code is maintained automatically, do not update it manually. 12:20:32-31.7.2017
predicates
    generatedInitialize : ().
clauses
    generatedInitialize() :-
        setFont(vpi::fontCreateByName("Tahoma", 8)),
        setText("DemoForm"),
        setRect(rct(50, 40, 382, 304)),
        setDecoration(titlebar([closeButton, maximizeButton, minimizeButton])),
        setBorder(sizeBorder()),
        setState([wsf_ClipSiblings, wsf_ClipChildren]),
        menuSet(noMenu),
        addDestroyListener(onDestroy),
        addMouseDownListener(onMouseDown),
        addMouseUpListener(onMouseUp),
        addSizeListener(onSize),
        setKeyUpResponder(onKeyUp),
        setPaintResponder(onPaint).
% end of automatic code

end implement demoForm
