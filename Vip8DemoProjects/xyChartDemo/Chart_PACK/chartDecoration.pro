% Copyright 2017 Harrison Pratt

implement chartDecoration

    open core, math, std, string, list
    open gdiplus_native, gdiplus, color
    open font, fontFamily

constants

    %- coefficients used to scale a font to fit a fraction of a rectangle
    fscaleToEmSizeFactorWIDTH : real = 0.85.
    fscaleToEmSizeFactorHEIGHT : real = 0.85.

    fscaleToEmSizeFactorVERTICAL : real = 0.75. % reduce VERTICAL TEXT to fit this fraction of destination rectangle

    %-- the maximum size to draw characters.  This is arbitrary for now.
    fSizeMaxPixelsH : real = 160.0.
    fSizeMaxPixelsV : real = 80.0.

    %-- names of fonts to use for labelling the chart
    fNameTITLE = "Times New Roman". % used for top center label of chart
    fNameLABEL = "Lucida Sans". % used for axis labels
    fNameVALUE = "Lucida Sans". % used for axis values at tics & grids
    fNameDEFAULT = "Arial".

    %-- font styles to use for labelling the chart
    fstyleTITLE : integer = gdiplus_native::fontStyleBold.
    fstyleVALUE : integer = gdiplus_native::fontStyleRegular.
    fstyleLABEL : integer = gdiplus_native::fontStyleRegular.
%    fstyleDEFAULT : integer = gdiplus_native::fontStyleRegular.

clauses

    fontTitleScaled_EM(RectF) = F :-
        % scale Title to Width
        AdjEmSize = scaleToRect_EM(RectF),
        FFamily = fontFamily::createFromName(fNameTITLE),
        F = font::createFromFontFamily(FFamily, AdjEmSize, fstyleTITLE, unitPixel).

%    fontValueScaled_StrY( G, S, RectValueX, RectValueY ) = F :-  % NOTE: this should work for X & Y
%        RectValueX = gdiplus::rectF( _Lx,_Tx,_Wx,Hx ),
%        RectValueY = gdiplus::rectF( _Ly,_Ty,Wy,_Hy ),
%        F0 = fontValues(),
%        EmSizeRectX = emSizeToFitHeight( G, S, F0, trunc(Hx) ),
%        EmSizeRectY = emSizeToFitWidth( G, S, F0, trunc(Wy) ),
%        EmSize = lesser( EmSizeRectX, EmSizeRectY ),
%        FFamily = F0:fontfamily,
%        F = font::createFromFontFamily( FFamily, EmSize, fstyleVALUE, unitPixel ).

    fontAxisLabelsXY(G, ValuesYY, DecimalsY, RectValueX, RectValueY) = F :-
        [Y0 | _] = ValuesYY,
        !,
        FormatStrY = chartDecoration::axisValueFormatDecimals(DecimalsY),
        TestStr = string::format(FormatStrY, Y0), % all values are same size due to string formatting
        RectValueX = gdiplus::rectF(_Lx, _Tx, _Wx, Hx),
        RectValueY = gdiplus::rectF(_Ly, _Ty, Wy, _Hy),
        F0 = fontValues(),
        EmSizeRectX = emSizeToFitHeight(G, TestStr, F0, trunc(Hx)),
        EmSizeRectY = emSizeToFitWidth(G, TestStr, F0, trunc(Wy)),
        EmSize = lesser(EmSizeRectX, EmSizeRectY),
        FFamily = F0:fontfamily,
        F = font::createFromFontFamily(FFamily, EmSize, fstyleVALUE, unitPixel).
    fontAxisLabelsXY(_G, _ValuesYY, _DecimalsY, _RectValueX, _RectValueY) = F :-
        decorationErrorMsg(predicate_fullname(), "Y Value List is empty.  Default font is used."),
        F = fontDefault().

    fontValueScaled_EM(RectF) = F :-
        % scale Value to fit rectangle's Width and Height
        RectF = gdiplus::rectF(_, _, RectWidth, RectHeight),
        AdjEmSizeW = lesser(fSizeMaxPixelsH, RectWidth * fscaleToEmSizeFactorWIDTH),
        AdjEmSizeH = lesser(fSizeMaxPixelsV, RectHeight * fscaleToEmSizeFactorHEIGHT),
        EmSize = lesser(AdjEmSizeW, AdjEmSizeH),
        FFamily = fontFamily::createFromName(fNameVALUE),
        F = font::createFromFontFamily(FFamily, EmSize, fstyleVALUE, unitPixel).

    fontLabelScaled_EM(RectF) = F :-
        % scale Label to Height
        AdjEmSize = scaleToRect_EM(RectF),
        FFamily = fontFamily::createFromName(fNameLABEL),
        F = font::createFromFontFamily(FFamily, AdjEmSize, fstyleLABEL, unitPixel).

    fontLabelFitWidth_EM(G, S, CurrFont, WidthAvail) = F :-
        EmSize = emSizeToFitWidth(G, S, CurrFont, WidthAvail),
        F = font::createFromFontFamily(CurrFont:fontfamily, EmSize, fstyleLABEL, unitPixel).

    fontLabelFitHeight_EM(G, S, CurrFont, HeightAvail) = F :-
        EmSize = emSizeToFitHeight(G, S, CurrFont, HeightAvail),
        F = font::createFromFontFamily(CurrFont:fontfamily, EmSize, fstyleLABEL, unitPixel).

    fontLabelFitRectF_EM(G, S, CurrFont, gdiplus::rectF(_X, _Y, HeightAvail, WidthAvail)) = F :-
        EmWidth = emSizeToFitWidth(G, S, CurrFont, trunc(WidthAvail)),
        EmHeight = emSizeToFitHeight(G, S, CurrFont, trunc(HeightAvail)),
        EmSize = lesser(EmWidth, EmHeight),
        F = font::createFromFontFamily(CurrFont:fontfamily, EmSize, fstyleLABEL, unitPixel).

    font_EM_size(G, CurrFont, WidthEM, HeightEM) :-
        G:measureString("M", CurrFONT, trialRectF, stringFormat::create(), BoundBox, _, _),
        BoundBox = gdiplus::rectF(_, _, W, H),
        WidthEM = round(W),
        HeightEM = round(H).

    fontLabelFitRectFVertical_EM(G, S, CurrFont, gdiplus::rectF(_X, _Y, WidthAvail, HeightAvail)) = F :-
        EmWidth = emSizeToFitWidth(G, "M", CurrFont, trunc(WidthAvail)),
        EmHeight = emSizeToFitVerticalText(G, S, CurrFont, trunc(HeightAvail)),
        EmSize = lesser(EmWidth, EmHeight),
        F = font::createFromFontFamily(CurrFont:fontfamily, EmSize, fstyleLABEL, unitPixel).

    emSizeToFitWidth(G, S, CurrFont, WidthAvail) = NewEmSizeR :-
        G:measureString(S, CurrFONT, trialRectF, stringFormat::create(), BoundBox, _, _),
        BoundBox = gdiplus::rectF(_, _, WidthStr, _),
        CurrEmSizeR = CurrFont:size,
        NewEmSizeR = CurrEmSizeR * (WidthAvail / WidthStr).

    emSizeToFitHeight(G, S, CurrFont, HeightAvail) = NewEmSizeR :-
        G:measureString(S, CurrFONT, trialRectF, stringFormat::create(), BoundBox, _, _),
        BoundBox = gdiplus::rectF(_, _, _WidthStr, HeightStr),
        CurrEmSizeR = CurrFont:size,
        NewEmSizeR = CurrEmSizeR * (HeightAvail / HeightStr).

class predicates
    emSizeToFitVerticalText : (graphics, string, font CurrFont, integer HeightAvail) -> real EmSizeNeeded.
clauses
    emSizeToFitVerticalText(G, S, CurrFont, HeightAvail) = NewEmSizeR :-
%                    G:measureString("M",some(CurrFont), trialRectF, none(), BoundBox, _Cpts,_Lines),
        G:measureString("M", CurrFONT, trialRectF, stringFormat::create(), BoundBox, _, _), % HWP 2018-11-04 VIP 8 upgrade
        BoundBox = gdiplus::rectF(_, _, _WidthStr, HeightStr),
        CurrEmSizeR = CurrFont:size,
        NewEmSizeR = fscaleToEmSizeFactorVERTICAL * (CurrEmSizeR * (HeightAvail / HeightStr)) / string::length(S).

class predicates
    lesser : (real, real) -> real.
clauses
    lesser(R1, R2) = R1 :-
        R1 <= R2,
        !.
    lesser(_, R2) = R2.

class predicates
    scaleToRect_EM : (gdiplus::rectF FitToRECTF) -> real ScaleFactor.
clauses
    scaleToRect_EM(gdiplus::rectF(_X, _Y, Width, Height)) = ScaleFactor :-
        PossibleHeight = lesser(fSizeMaxPixelsV, Height * fscaleToEmSizeFactorHEIGHT),
        PossibleWidth = lesser(fSizeMaxPixelsH, Width * fscaleToEmSizeFactorWIDTH),
        ScaleFactor = lesser(PossibleHeight, PossibleWidth).

/******************************************************************************

                    |		A
	Font height		|		A	ASCENT
		aka			|		A
	Line spacing	|		A
        aka         |		A
    Size            |	    D	DESCENT
                    |		D
                    |		D
                    |		L	LEADING
                    |		L

    See: https://www.w3schools.com/css/css_font.asp  for EM size

    See: https://www.w3schools.com/cssref/css_websafe_fonts.asp for selecting good fonts to use

    See: https://www.w3schools.com/cssref/css_pxtoemconversion.asp for converting EM <--> pixels

******************************************************************************/

    fontLeadingPxHalf(F) = HalfLeadingPx32 :-
        HalfLeadingPx32 = convert(real32, fontLeadingPx(F) / 2.0).

    fontLeadingPx(F) = LeadingPx32 :-
        %  https://docs.microsoft.com/en-us/dotnet/framework/winforms/advanced/how-to-obtain-font-metrics
        FStyle = F:style,
        EmHeightDu = F:fontfamily:getEmHeight(FStyle), % Du = design units
        PxPerDu = fontPixelsPerDu(F),
        SpacingDu = F:fontFamily:getLineSpacing(FStyle),
        LeadingPx32 = convert(real32, (SpacingDu - EmHeightDu) * PxPerDu).

class predicates
    fontPixelsPerDu : (font) -> real32 PixelsPerDesignUnit.
clauses
    fontPixelsPerDu(F) = Px32 :-
        Px32 = convert(real32, F:size / F:fontFamily:getEmHeight(F:style)).

/******************************************************************************
				SMALL SUPPORT CLAUSS LOCAL TO CLASS
******************************************************************************/

clauses

    verticalStr(S) = embedString(S, "\n").  % Used to draw vertical labels

    explodedStr(S) = embedString(S, " ").  % can use to expand Title text if desired

class predicates
    embedString : (string StrToExpand, string StrToInsert) -> string ExpandedString.
    % Embeds StrToInsert between each character of StrToExpand.
    % Does not prefix or suffix StrToExpand with StrToInsert.
clauses
    embedString(S, ExpWith) = ExpandedString :-
        OS = outputStream_string::new(),
        LastX = string::length(S) - 1,
        foreach X = std::fromTo(0, LastX) do
            OS:write(string::subChar(S, X)),
            if X < LastX then
                OS:write(ExpWith)
            end if
        end foreach,
        ExpandedString = OS:getString(),
        OS:close().

class predicates
    decorationErrorMsg : (string, string).
clauses
    decorationErrorMsg(TitleSuffix, Msg) :-
        vpiCommonDialogs::error(concat("ERROR in ", TitleSuffix), Msg).

/******************************************************************************
                    PENS, BRUSHES & FONTS
******************************************************************************/

clauses % for drawing attributes

    rctPenDefault() = pen::createColor(color::create(color::black), 1, unitPixel).

    % rctPenDataRct() = pen::createColor( color::create( color::black ), 2, unitPixel ).

    penGrid() = pen::createColor(color::create(color::gray), 1, unitPixel).

    penGridMajorH() = P :-
        P = penGrid(),
        P:width := 1.

    penGridMajorV() = P :-
        P = penGrid(),
        P:width := 1.

    penGridMinorH() = P :-
        P = penGrid(),
        P:dashStyle := dashStyleDot.

    penGridMinorV() = P :-
        P = penGrid(),
        P:dashStyle := dashStyleDot.

    penDataAxes() = P :-
        P = pen::createColor(color::create(color::gray), 1, unitPixel).

    fontDefault() = FONT :-
        FF = fontFamily::createFromName(fNameDEFAULT),
        FS = 0,
        FONT = font::createFromFontFamily(FF, 8, FS, unitPixel).

    fontValues() = FONT :-
        FF = fontFamily::createFromName(fNameVALUE),
        FS = 0,
        FONT = font::createFromFontFamily(FF, 8, FS, unitPixel).

    fontLabels() = FONT :-
        FF = fontFamily::createFromName(fNameLABEL),
        FS = 0,
        FONT = font::createFromFontFamily(FF, 8, FS, unitPixel).

    %-- pen and brush for drawing the axis value labels; may want to elaborate these later
    brushValueText() = B :-
        P = penValueText(),
        B = P:brush.

    penValueText() = P :-
        P = pen::create().

/******************************************************************************
    PENS AND BRUSHES FOR INDEXED GRAPH SERIES
******************************************************************************/

class predicates

    p : (integer Index0, unsigned Color, real Width) multi (o,o,o) determ (i,o,o).
    pDash : (integer Index0, gdiplus_native::gpDashStyle [out]) determ.

    b : (integer Index0, unsigned Color, real Width) multi (o,o,o) determ (i,o,o).

clauses % numbered pen and brush attributes

    p(0, color::darkred, 2.0).
    p(1, color::darkblue, 2.0).
    p(2, color::darkgreen, 2.0).
    p(3, color::darksalmon, 2.0).  % darksalmon doesn't contrast very well with salmon
    p(4, color::darkcyan, 2.0).
    p(5, color::darkmagenta, 1.0).
    p(6, color::darkorange, 1.0).
    p(7, color::darkturquoise, 1.0).
    p(8, color::darkslateblue, 1.0).
    p(9, color::darkgoldenrod, 1.0).

    pDash(0, dashStyleSolid).
    pDash(1, dashStyleDash).
    pDash(2, dashStyleDot).
    pDash(3, dashStyleDashDot).
    pDash(4, dashStyleDashDotDot).
        % NOTE: the patterns repeat;  later you can work out custom GpDashStyle's (see MSDN)
    pDash(5, dashStyleSolid).
    pDash(6, dashStyleDash).
    pDash(7, dashStyleDot).
    pDash(8, dashStyleDashDot).
    pDash(9, dashStyleDashDotDot).

    b(0, color::red, 1.0).
    b(1, color::blue, 1.0).
    b(2, color::green, 1.0).
    b(3, color::salmon, 1.0).
    b(4, color::cyan, 1.0).
    b(5, color::magenta, 1.0).
    b(6, color::orange, 1.0).
    b(7, color::turquoise, 1.0).
    b(8, color::slateblue, 1.0).
    b(9, color::goldenrod, 1.0).

clauses % get pen or brush with attributes specified by number
    /*
        NOTE:  Some pens above have a non-solid dashStyle so you
            will want to over-ride the indexed dashStyle
            with dashStyleSolid when drawing the plotted point,
            otherwise the plotted point may look ragged.
    */
    penNum(PenNum) = P :-
        p(PenNum, C, Width),
        pDash(PenNum, Style),
        !,
        P = pen::createColor(color::create(C), Width, unitPixel),
        P:dashStyle := Style.
    penNum(_) = P :-
        P = pen::createColor(color::create(color::black), 1, unitPixel).

    penNumWidth(PenNum) = W :-
        p(PenNum, _, W),
        !.
    penNumWidth(_) = 1.0.

    penNumColor(PenNum) = UnsignedColor :-
        p(PenNum, UnsignedColor, _),
        !.
    penNumColor(_) = color::black.

    brushNum(BrushNum) = B :-
        b(BrushNum, C, W),
        !,
        P = pen::createColor(color::create(C), W, unitPixel),
        B = P:brush.
    brushNum(_) = B :-
        P = pen::createColor(color::create(color::black), 1, unitPixel),
        B = P:brush.

    brushNumWidth(BrushNum) = W :-
        b(BrushNum, _, W),
        !.
    brushNumWidth(_) = 1.0.

    brushNumColor(BrushNum) = UnsignedColor :-
        b(BrushNum, UnsignedColor, _),
        !.
    brushNumColor(_) = color::black.

    penNumList() = [ PN || p(PN, _, _) ].

    brushNumList() = [ BN || b(BN, _, _) ].

    penDefault() = pen::createColor(color::create(color::black), 1, unitPixel).

    brushDefault() = B :-
        P = penDefault(),
        B = P:brush.

    axisValueFormatDecimals(NumDecimals) = FmtString :-
        NumDecimals >= 0,
        !,
        FmtString = string::concat("%3.", toString(NumDecimals)).
    axisValueFormatDecimals(N) = FS :-
        vpiCommonDialogs::error(predicate_fullname(), format("Decimals must be >= 0.\n\nYour input: % ", N)),
        FS = concat(predicate_fullname(), " %3.0").

    maxDrawWidthReals(G, FONT, RR, FS) = Width32 :-
%        MW = varM::new(  convert(real32,0.0)  ),
        MW = varM::new(0), % HWP 2018-11-04 VIP 8 upgrade
        foreach E = list::getMember_nd(RR) do
            S = string::format(FS, E),
%            G:measureString(  S, some(FONT), trialRectF, none(), BoundBox ,_CodePointsFitted,_LinesFitted),
            G:measureString(S, FONT, trialRectF, stringFormat::create(), BoundBox, _, _), % HWP 2018-11-04 VIP 8 upgrade
            BoundBox = gdiplus::rectf(_, _, W, _),
            if W > MW:value then
                MW:value := W
            end if
        end foreach,
        Width32 = MW:value.

    maxDrawWidthStrings(G, FONT, SS) = Width32 :-
%        MW = varM::new(  convert(real32,0.0)  ),
        MW = varM::new(0), % HWP 2018-11-04 VIP 8 upgrade
        foreach S = list::getMember_nd(SS) do
%            G:measureString(  S, some(FONT), trialRectF, none(), BoundBox ,_CodePointsFitted,_LinesFitted),
            G:measureString(S, FONT, trialRectF, stringFormat::create(), BoundBox, _, _), % HWP 2018-11-04 VIP 8 upgrade
            BoundBox = gdiplus::rectf(_, _, W, _),
            if W > MW:value then
                MW:value := W
            end if
        end foreach,
        Width32 = MW:value.

    showPenAndBrushColors(G) :-
        % a test predicate to show the numbered brushes and pens.
        FONT = font::createFromFontFamily(fontDefault():fontfamily, 20, 0, unitPixel),
        DrawFmt = stringFormat::create(),
        DrawFmt:alignment := stringAlignmentCenter,
        DrawFmt:lineAlignment := stringAlignmentCenter,
        Size = 50,
        foreach N = getMember_nd(chartDecoration::penNumList()) do
            X = Size * N,
            Y = Size * N,
            RctF = gdiplus::rectF(X, Y, Size, Size),
            Brush = chartDecoration::brushNum(N),
            Pen = chartDecoration::penNum(N),
            Pen:width := 2,
            G:fillRectangleF(Brush, RctF),
            G:drawLineF(Pen, pointf(X + Size, Y + Size / 2), pointF(100 + X + Size, Y + Size / 2)),
            Pen:dashStyle := dashStyleSolid,
            G:drawRectangleF(Pen, RctF),
%            G:drawString( toString(N),some(FONT),RctF,some(DrawFmt),some( brushDefault() ))
            G:drawString(toString(N), FONT, RctF, DrawFmt, brushDefault()) % HWP 2018-11-04 VIP 8 upgrade

        end foreach.

end implement chartDecoration
