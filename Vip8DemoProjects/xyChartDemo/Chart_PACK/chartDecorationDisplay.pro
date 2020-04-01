% Copyright 2017 Harrison Pratt

implement chartDecorationDisplay
    inherits formWindow
    open core, vpiDomains

clauses
    display(Parent) = Form :-
        Form = new(Parent),
        Form:setText("Chart Decoration Colors and Line Styles"),
        Form:show().

clauses
    new(Parent):-
        formWindow::new(Parent),
        generatedInitialize().

predicates
    onPaint : window::paintResponder.
clauses
    onPaint(_Source, _Rectangle, GDI):-

        HDC = GDI:getNativeGraphicContext(IsReleaseNeeded),

        Graphics = graphics::createFromHDC(HDC),
        Graphics:smoothingMode := gdiplus_native::smoothingModeAntiAlias,  % the default is unsmoothed
        chartDecoration::showPenAndBrushColors( Graphics ),

        GDI:releaseNativeGraphicContext(HDC,IsReleaseNeeded).

% This code is maintained automatically, do not update it manually. 11:48:42-2.7.2017
predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setFont(vpi::fontCreateByName("Tahoma", 8)),
        setText("chartDecorationDisplay"),
        setRect(rct(50,40,471,362)),
        setDecoration(titlebar([closeButton,maximizeButton,minimizeButton])),
        setBorder(sizeBorder()),
        setState([wsf_ClipSiblings,wsf_ClipChildren]),
        menuSet(noMenu),
        setPaintResponder(onPaint).
% end of automatic code
end implement chartDecorationDisplay