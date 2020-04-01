% Copyright 2017 Harrison Pratt

implement chart_Core

    open core, gdiplus_native, gdiplus
    open math

facts - propertyDB

    %-- options for drawing data
    doConnectPoints_fact : boolean := true. % if TRUE draw XY lines; if FALSE draw XY as a scatterplot

    %-- dimensions of the data rectangle in Pixels
    dataPxB_fact : integer := erroneous.
    dataPxL_fact : integer := erroneous.
    dataPxR_fact : integer := erroneous.
    dataPxT_fact : integer := erroneous.
    dataPxWidth_fact : integer := erroneous.
    dataPxHeight_fact : integer := erroneous.

    %-- dimensions of the drawing window (client window) in Pixels
    drawPxB_fact : integer := erroneous.
    drawPxL_fact : integer := erroneous.
    drawPxR_fact : integer := erroneous.
    drawPxT_fact : integer := erroneous.
    drawPxHeight_fact : integer := erroneous.
    drawPxWidth_fact : integer := erroneous.

    %-- scaling related properties
    axisPixelsRealX_fact : real := erroneous.
    axisPixelsRealY_fact : real := erroneous.
    valueMaxX_fact : real := erroneous.
    valueMaxY_fact : real := erroneous.
    valueMinX_fact : real := erroneous.
    valueRangeX_fact : real := erroneous.
    valueRangeY_fact : real := erroneous.
    valueMinY_fact : real := erroneous.

    %-- axis value display decimal places
    axisDecimalsX_fact : integer := 0.
    axisDecimalsY_fact : integer := 0.

    %-- graph labels.  If not empty string, then draw label
    labelBottom_fact : string := "".
    labelLeft_fact : string := "".
    labelRight_fact : string := "".
    labelTitle_fact : string := "".

    %-- Increments for drawing gridlines and axis values.
    %-- If <> 0.0 then draw gridlines and values; default is 0.0 (no grid or labels drawn).
    gridStepMajorX_fact : real := 0.0.
    gridStepMinorX_fact : real := 0.0.
    gridStepMajorY_fact : real := 0.0.
    gridStepMinorY_fact : real := 0.0.

    %-- Initial Legend position is at left, top of dataZone rectangle.
    %-- increment these insets to relocate the legend on the graph
    %-- Reasonable range is 0.0 - 0.9; negative values will move legend out of data range, as will values > 1.0
    %-- Position is that of the left,top of first legend string
    legendInsetRatioX_fact : real := 0.05.
    legendInsetRatioY_fact : real := 0.05.
    legendOuterRectF_fact : gdiplus::rectF := erroneous.
    legendMoveMode_fact : boolean := false. % TRUE when trying to move the legend interactively

clauses % for properties: PLOT AREA WHERE DATA IS DISPLAYED

    dataPxB() = dataPxB_fact.  % getter
    dataPxB(INTEGER) :-
        dataPxB_fact := INTEGER.  % setter

    dataPxHeight() = dataPxHeight_fact.  % getter
    dataPxHeight(INTEGER) :-
        dataPxHeight_fact := INTEGER.  % setter

    dataPxL() = dataPxL_fact.  % getter
    dataPxL(INTEGER) :-
        dataPxL_fact := INTEGER.  % setter

    dataPxR() = dataPxR_fact.  % getter
    dataPxR(INTEGER) :-
        dataPxR_fact := INTEGER.  % setter

    dataPxT() = dataPxT_fact.  % getter
    dataPxT(INTEGER) :-
        dataPxT_fact := INTEGER.  % setter

    dataPxWidth() = dataPxWidth_fact.  % getter
    dataPxWidth(INTEGER) :-
        dataPxWidth_fact := INTEGER.  % setter

clauses % for properties: AREA INSET FROM WINDOW, WHERE ALL DRAWING IS DONE.  OUTSIDE THIS IS THE EMPTY "BORDER"

    drawPxB() = drawPxB_fact.  % getter
    drawPxB(INTEGER) :-
        drawPxB_fact := INTEGER.  % setter

    drawPxL() = drawPxL_fact.  % getter
    drawPxL(INTEGER) :-
        drawPxL_fact := INTEGER.  % setter

    drawPxR() = drawPxR_fact.  % getter
    drawPxR(INTEGER) :-
        drawPxR_fact := INTEGER.  % setter

    drawPxT() = drawPxT_fact.  % getter
    drawPxT(INTEGER) :-
        drawPxT_fact := INTEGER.  % setter

    drawPxHeight() = drawPxHeight_fact.  % getter
    drawPxHeight(INTEGER) :-
        drawPxHeight_fact := INTEGER.  % setter

    drawPxWidth() = drawPxWidth_fact.  % getter
    drawPxWidth(INTEGER) :-
        drawPxWidth_fact := INTEGER.  % setter

clauses % for properties:  AXIS DIMENSIONS AS REAL VALUES AND PIXELS, USED FOR SCALING DATA TO WINDOW

    axisPixelsRealX() = axisPixelsRealX_fact.  % getter
    axisPixelsRealX(REAL) :-
        axisPixelsRealX_fact := REAL.  % setter

    axisPixelsRealY() = axisPixelsRealY_fact.  % getter
    axisPixelsRealY(REAL) :-
        axisPixelsRealY_fact := REAL.  % setter

    valueMaxX() = valueMaxX_fact.  % getter
    valueMaxX(REAL) :-
        valueMaxX_fact := REAL.  % setter

    valueMaxY() = valueMaxY_fact.  % getter
    valueMaxY(REAL) :-
        valueMaxY_fact := REAL.  % setter

    valueMinX() = valueMinX_fact.  % getter
    valueMinX(REAL) :-
        valueMinX_fact := REAL.  % setter

    valueRangeX() = valueRangeX_fact.  % getter
    valueRangeX(REAL) :-
        valueRangeX_fact := REAL.  % setter

    valueRangeY() = valueRangeY_fact.  % getter
    valueRangeY(REAL) :-
        valueRangeY_fact := REAL.  % setter

    valueMinY() = valueMinY_fact.  % getter
    valueMinY(REAL) :-
        valueMinY_fact := REAL.  % setter

    gridStepMajorY() = gridStepMajorY_fact.  % getter
    gridStepMajorY(REAL) :-
        gridStepMajorY_fact := REAL.  % setter

    gridStepMajorX() = gridStepMajorX_fact.  % getter
    gridStepMajorX(REAL) :-
        gridStepMajorX_fact := REAL.  % setter

    gridStepMinorX() = gridStepMinorX_fact.  % getter
    gridStepMinorX(REAL) :-
        gridStepMinorX_fact := REAL.  % setter

    gridStepMinorY() = gridStepMinorY_fact.  % getter
    gridStepMinorY(REAL) :-
        gridStepMinorY_fact := REAL.  % setter

clauses % for properties: THE STRINGS USED TO LABEL THE CHART

    %-- graph labels
    labelBottom() = labelBottom_fact.  % getter
    labelBottom(STRING) :-
        labelBottom_fact := STRING.  % setter

    labelLeft() = labelLeft_fact.  % getter
    labelLeft(STRING) :-
        labelLeft_fact := STRING.  % setter

    labelRight() = labelRight_fact.  % getter
    labelRight(STRING) :-
        labelRight_fact := STRING.  % setter

    labelTitle() = labelTitle_fact.  % getter
    labelTitle(STRING) :-
        labelTitle_fact := STRING.  % setter

clauses % for properties: DECIMAL PLACES USED FOR FORMATING AXIS VALUES DISPLAY

    axisDecimalsX() = axisDecimalsX_fact.  % getter
    axisDecimalsX(INTEGER) :-
        axisDecimalsX_fact := INTEGER.  % setter

    axisDecimalsY() = axisDecimalsY_fact.  % getter
    axisDecimalsY(INTEGER) :-
        axisDecimalsY_fact := INTEGER.  % setter

clauses % for properties: LEGEND POSITIONING

    legendInsetRatioX() = legendInsetRatioX_fact.  % getter
    legendInsetRatioX(REAL) :-
        legendInsetRatioX_fact := REAL.  % setter

    legendInsetRatioY() = legendInsetRatioY_fact.  % getter
    legendInsetRatioY(REAL) :-
        legendInsetRatioY_fact := REAL.  % setter

    legendOuterRectF() = legendOuterRectF_fact.  % getter
    legendOuterRectF(GDIPLUS_RECTF) :-
        legendOuterRectF_fact := GDIPLUS_RECTF.  % setter

    legendMoveMode() = legendMoveMode_fact.  % getter
    legendMoveMode(BOOLEAN) :-
        legendMoveMode_fact := BOOLEAN.  % setter

clauses % for properties: CHART DRAWING OPTIONS

    doConnectPoints() = doConnectPoints_fact.  % getter
    doConnectPoints(BOOLEAN) :-
        doConnectPoints_fact := BOOLEAN.  % setter

predicates

    zone_attrib : (zoneDom, zoneTextOrient_HV_Dom [out], stringAlignment [out], stringAlignment [out], zoneRectLineWidth [out],
        zoneRectLineColor [out], zoneRectFillColor [out]).

clauses
%                 ZONE				ORIENTATION			H_ALIGN			            V_ALIGN			      WIDTH  	FG_COLOR	 BG_COLOR
    zone_attrib(zoneData, zTextOrient_NA, stringAlignmentNear, stringAlignmentNear, 0, color::black, color::white).
    zone_attrib(zoneDrawing, zTextOrient_NA, stringAlignmentNear, stringAlignmentNear, 0, color::black, color::white).

    zone_attrib(zoneLabelTitle, zTextOrient_H, stringAlignmentCenter, stringAlignmentNear, 1, color::gray, color::white).
    zone_attrib(zoneLabelBottom, zTextOrient_H, stringAlignmentCenter, stringAlignmentCenter, 1, color::gray, color::white).
    zone_attrib(zoneLabelYL, zTextOrient_V, stringAlignmentCenter, stringAlignmentCenter, 1, color::gray, color::white).
    zone_attrib(zoneLabelYR, zTextOrient_V, stringAlignmentCenter, stringAlignmentCenter, 1, color::gray, color::white).

    zone_attrib(zoneValuesX, zTextOrient_H, stringAlignmentCenter, stringAlignmentCenter, 1, color::gray, color::white).
    zone_attrib(zoneValuesYL, zTextOrient_H, stringAlignmentFar, stringAlignmentCenter, 1, color::gray, color::white).
    zone_attrib(zoneValuesYR, zTextOrient_V, stringAlignmentFar, stringAlignmentCenter, 1, color::gray, color::white).

clauses

    getZoneAlignH(ZONE) = Align_L_C_R :-
        zone_attrib(ZONE, _Dir_H_or_V, Align_L_C_R, _Align_T_C_B, _LineWidth, _LineColor, _FillColor).

    getZoneAlignV(ZONE) = Align_T_C_B :-
        zone_attrib(ZONE, _Dir_H_or_V, _Align_L_C_R, Align_T_C_B, _LineWidth, _LineColor, _FillColor).

    getZoneOrientationHV(ZONE) = Text_Horiz_Vert :-
        zone_attrib(ZONE, Text_Horiz_Vert, _Align_L_C_R, _Align_T_C_B, _LineWidth, _LineColor, _FillColor).

/******************************************************************************

******************************************************************************/

clauses % for calculations using zone dimensions

    zone_LTRB(zoneData) = tuple(dataPxL, dataPxT, dataPxR, dataPxB).
    zone_LTRB(zoneDrawing) = tuple(drawPxL, drawPxT, drawPxR, drawPxB).
    zone_LTRB(zoneValuesYL) = tuple(L, T, R, B) :-
        L = dataPxL - labelValueDiv2PxX(),
        T = dataPxT,
        R = dataPxL - zoneGapPxX,
        B = dataPxB.
    zone_LTRB(zoneLabelYL) = tuple(L, T, R, B) :-
        L = drawPxL,
        T = dataPxT,
        R = dataPxL - labelValueDiv2PxX() - zoneGapPxX,
        B = dataPxB.
    zone_LTRB(zoneValuesYR) = tuple(L, T, R, B) :-
        L = dataPxR + zoneGapPxX,
        T = dataPxT,
        R = datapxR + labelValueDiv2PxX(),
        B = dataPxB.
    zone_LTRB(zoneLabelYR) = tuple(L, T, R, B) :-
        L = dataPxR + labelValueDiv2PxX() + zoneGapPxX,
        T = dataPxT,
        R = drawPxR,
        B = dataPxB.
    zone_LTRB(zoneValuesX) = tuple(L, T, R, B) :-
        L = dataPxL,
        T = dataPxB + zoneGapPxY,
        R = dataPxR,
        B = dataPxB + labelValueDiv2PxY().
    zone_LTRB(zoneLabelBottom) = tuple(L, T, R, B) :-
        L = drawPxL + zoneGapPxX,
        T = dataPxB + labelValueDiv2PxY(),
        R = drawPxR - zoneGapPxX,
        B = drawPxB + zoneGapPxY.
    zone_LTRB(zoneLabelTitle) = tuple(L, T, R, B) :-
        L = drawPxL + zoneGapPxX,
        T = drawPxT,
        R = drawPxR - zoneGapPxX,
        B = dataPxt - zoneGapPxY.

%-- labelValueDiv2Px_ is 1/2 the space between the data rectangle and the drawing rectangle
predicates
    labelValueDiv2PxX : () -> integer PixelsAvailableForLabel.
clauses
    labelValueDiv2PxX() = AvailablePX :-
        AvailablePX = (dataPxL - drawPxL) div 2.

predicates
    labelValueDiv2PxY : () -> integer PixelsAvailableForLabel.
clauses
    labelValueDiv2PxY() = AvailablePX :-
        AvailablePX = (drawPxB - dataPxB) div 2.

    zone_LTWH(ZoneDom) = tuple(L, T, R - L, B - T) :-
        tuple(L, T, R, B) = zone_LTRB(ZoneDom).

    zone_rectI(ZoneDom) = gdiplus::rectI(L, T, W, H) :-
        tuple(L, T, W, H) = zone_LTWH(ZoneDom).

    zone_rectF(ZoneDom) = gdiplus::rectF(LF, TF, WF, HF) :-
        tuple(L, T, W, H) = zone_LTWH(ZoneDom),
        LF = convert(real32, L),
        TF = convert(real32, T),
        WF = convert(real32, W),
        HF = convert(real32, H).

    zone_WHr32(ZoneDom) = tuple(PixelsW, PixelsH) :-
        gdiplus::rectF(_, _, PixelsW, PixelsH) = zone_rectF(ZoneDom).

    zone_Hr32(ZoneDom) = PixelsH :-
        tuple(_, PixelsH) = zone_WHr32(ZoneDom).

    zone_Wr32(ZoneDom) = PixelsW :-
        tuple(PixelsW, _) = zone_WHr32(ZoneDom).

    scaleChartToWIndow(W) :-

        W:getClientSize(ClientW, ClientH),

        %-- Scale the data drawing rectangle properties
        dataPxL := round(ClientW * insetDataAreaFraction),
        dataPxT := round(ClientH * insetDataAreaFraction),
        dataPxR := ClientW - dataPxL,
        dataPxB := ClientH - dataPxT,
        dataPxWidth := dataPxR - dataPxL,
        dataPxHeight := dataPxB - dataPxT,

        %-- define the area used to drawing, inside a small empty border
        drawPxL := round(ClientW * insetGraphAreaFraction),
        drawPxT := round(ClientH * insetGraphAreaFraction),
        drawPxR := ClientW - drawPxL,
        drawPxB := ClientH - drawPxT,
        drawPxHeight := drawPxB - drawPxT,
        drawPxWidth := drawPxR - drawPxL,

        %-- Scale drawing area
        axisPixelsRealX := dataPxR - dataPxL,
        axisPixelsRealY := dataPxB - dataPxT.

%----- CALCULATIONS -----------------------------------------------------------

clauses

    isInRangeX(R) :-
        R >= valueMinX,
        R <= valueMaxX.

    isInRangeY(R) :-
        R >= valueMinY,
        R <= valueMaxY.

    tryScaleToAxisX(RealX) = convert(real32, DrawPxX) :-
        isInRangeX(RealX),
        if valueRangeX <> 0.0 then
            DrawPxX = dataPxL + (RealX - valueMinX) / valueRangeX * dataPxWidth
        else
            DrawPxX =
                (dataPxL + dataPxR) / 2.0 % in horizontal center of data rectangle 2017-07-16
        end if.

    tryScaleToAxisY(RealY) = convert(real32, DrawPxY) :-
        isInRangeY(RealY),
        if valueRangeY <> 0.0 then
            DrawPxY = dataPxB - (RealY - valueMinY) / valueRangeY * dataPxHeight
        else
            DrawPxY =
                (dataPxB + dataPxt) / 2.0 % in vertical center of data rectangle 2017-07-16
        end if.

    axisValuesX(0.0) = [] :-
        !.
    axisValuesX(Step) = AxisLabelValues :-
        FromX = Step * trunc(valueMinX / Step),
        ToX = Step * trunc(valueMaxX / Step + 0),
        AxisLabelValues = chartCalculations::realsFromToStep(FromX, ToX, Step).

    axisValuesY(0.0) = [] :-
        !.
    axisValuesY(Step) = AxisLabelValues :-
        FromY = Step * trunc(valueMinY / Step),
        ToY = Step * trunc(valueMaxY / Step),
        AxisLabelValues = chartCalculations::realsFromToStep(FromY, ToY, Step).

    genXYpointF(X, Y) = pointF(tryScaleToAxisX(X), tryScaleToAxisY(Y)).

    calcXYPointSize() = Size32 :-
        Base = min(dataPxWidth, dataPxHeight),
        Factor = 0.02,
        Size32 = convert(real32, Base * Factor).

    insetRatio_fromPNT(vpiDomains::pnt(Px, Py), C) = tuple(InsetRatioX, InsetRatioY) :-
        % calculates inset from L,T of the chart Data Rectangle (i.e., the plot area)
        InsetRatioX = (Px - C:dataPxL) / C:dataPxWidth,
        InsetRatioY = (Py - C:dataPxT) / C:dataPxHeight.

end implement chart_Core
