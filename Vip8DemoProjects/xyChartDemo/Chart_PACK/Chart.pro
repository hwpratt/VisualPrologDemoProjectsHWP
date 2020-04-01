% Copyright 2017 Harrison Pratt

implement chart inherits chart_core

    open core, string, math, list, varM{ real }
    open vpiCommonDialogs
    open gdiplus, gdiplus_native, color
    open chartDecoration, chartCalculations

class facts - registryDB

    reg : ( string Name, chart ).

clauses

    new( Name ):-
        retractall( reg( Name, _) ),
        assert( reg( Name, This ) ).

    getChartNamed( NameCI ) = CHART :-
        reg( Name, CHART ),
            equalIgnoreCase(Name,NameCI), !.

    deregisterChartNamed( NameCI ) :-
        reg( Name, _CHART ),
            equalIgnoreCase(Name,NameCI),
            retractAll( reg( Name, _ ) ),
            fail.
    deregisterChartNamed( _ ).

/******************************************************************************
    DRAW ZONE LABELS (not values)
******************************************************************************/

predicates
    drawLabels : ( graphics, zoneDom_list, boolean BorderYN ).
clauses
    drawLabels( G, ZoneList, BorderYN ):-
        foreach Z = getMember_nd( ZoneList ) do
            drawLabel( G,Z,BorderYN )
        end foreach.

        predicates
            drawLabel : ( graphics, zoneDom, boolean BorderYN ).
                /* Draws a zone label in its rectangle and optionally draws the rectangle border for testing purposes.
                    Obtains string to draw from the zone property.
                    If the string is "" then no label is drawn, but the rectangle still optionally be drawn.
                */
        clauses
            drawLabel( G, Zone, BorderYN ):-
                if BorderYN = true then G:drawRectangleI( rctPenDefault(), zone_rectI(Zone) ) end if,
                LabelStr = zone_label(Zone),
                if LabelStr <> "" then
                    %-- create drawing format string for the zone
                    DrawFMT = stringFormat::create(),
                    DrawFMT:alignment := getZoneAlignH(Zone),
                    DrawFMT:lineAlignment := getZoneAlignV(Zone),
                    DrawFMT:formatFlags := stringFormatFlagsNoClip + stringFormatFlagsNoWrap,
                    %-- retrieve the font for the zone and scale it to the label rectangle
                    if Zone = zoneLabelTitle then
                            Font = fontTitleScaled_EM( zone_rectF( Zone ) ),
                            DisplayStr = LabelStr

                        elseif Zone = zoneLabelBottom then
                            Font = fontLabelScaled_EM( zone_rectF( Zone ) ),
                            DisplayStr = LabelStr

                        elseif isMember( Zone, [zoneLabelYL,zoneLabelYR] ) then
                            % NOTE: size the font using the unexpanded string
                            Font = fontLabelFitRectFVertical_EM( G, LabelStr, fontDefault(), zone_rectF( Zone ) ),
                            DisplayStr = verticalStr(LabelStr)  % insert carriage returns for vertical text

                        else
                            %-- unhandled zone error message
                            Font = fontDefault(),
                            DisplayStr = concat( "UNHANDLED ERROR for zone '", toString(Zone), "'  "),
                            stdio::writef("\n%  % ",predicate_fullname(),DisplayStr)
                    end if,

                    BRUSH = rctPenDefault():brush,
%                    G:drawString( DisplayStr, some( Font ), zone_rectF(Zone), some(DrawFMT), some(BRUSH) )
                    G:drawString( DisplayStr,  Font, zone_rectF(Zone), DrawFMT, BRUSH )   % HWP 2018-11-04 VIP 8 upgrade
                end if.

                    predicates
                        zone_label : ( zoneDom ) -> string.  % lookup table to simplify coding of label drawing
                    clauses
                        zone_label( zoneLabelBottom ) = labelBottom :- !.
                        zone_label( zoneLabelTitle ) = labelTitle :- !.
                        zone_label( zoneLabelYL ) = labelLeft :- !.
                        zone_label( zoneLabelYR ) = labelRight :- !.
                        zone_label( Z ) = concat( "ERROR:  ",toString(Z), " has no label" ).

/******************************************************************************

******************************************************************************/

facts - labelledDataDB

    datumXY : ( string ID, real X, real Y ).
        % For XY plots ( & future bivariate charts not yet implemented )

predicates
    getDataXY_ID_list : () -> string_list ID_List. % Unique, unsorted
clauses
    getDataXY_ID_list() = ID_STRINGS :-
        ID_STRINGS = removeDuplicates( [ S || datumXY(S,_,_) ] ).

clauses

    putDataListXY( ID, XYLIST) :-
        foreach xy(X,Y) = getMember_nd(XYLIST) do
            putDatumXY(ID, xy(X,Y) )
        end foreach.

    putDatumXY( ID, xy(X,Y) ):-
        assert( datumXY(ID,X,Y) ).

    clearDataXY():-
        retractall( datumXY(_,_,_) ).

    clearDataXY( ID ):-
        retractall( datumXY( ID,_,_) ).

    readDataXY_fromIO():-
        clearDataXY(),
        foreach chartIO::getSXY_nd(S,X,Y) do
            putDatumXY(S,xy(X,Y) )
        end foreach,
        updatePropertiesXY().

    updatePropertiesXY():-
        % QUESTION: do you need to specify the ID here?
        % No, because we scale for ALL data series
        tuple( MinX,MaxX ) = realMinMax( [ X || datumxy(_,X,_ ) ] ),
        tuple( MinY,MaxY ) = realMinMax( [ Y || datumXY(_,_,Y) ] ),
        !,
        valueMinX := MinX,
        valueMaxX := MaxX,
        valueMinY := MinY,
        valueMaxY := MaxY,
        valueRangeX := MaxX - MinX,
        valueRangeY := MaxY - MinY.
    updatePropertiesXY():-
        error( concat( "ERROR: ",predicate_fullname()),"Chart has no data."),
        stdio::write("\n",predicate_fullname(), " FAILED: Chart has no data." ).

    setDataDisplayRangeX( MinX, MaxX ):-
        valueMinX := MinX,
        valueMaxX := MaxX,
        valueRangeX := MaxX - MinX.

    setDataDisplayRangeY( MinY, MaxY ):-
        valueMinY := MinY,
        valueMaxY := MaxY,
        valueRangeY := MaxY - MinY.

    setDataDisplayRangesXY(  MinX,  MaxX,  MinY,  MaxY ):-
        setDataDisplayRangeX( MinX, MaxX ),
        setDataDisplayRangeY( MinY, MaxY ).

    setLabelsLTRB( LabelL, LabelT, LabelR, LabelB ):-
        labelBottom := LabelB,
        labelTitle := LabelT,
        labelLeft := LabelL,
        labelRight := LabelR.

/******************************************************************************
                CALCULATIONS
******************************************************************************/
domains
    pointF_list = pointF*.
predicates
    getXYpointF_list : ( string ID, boolean SortYN ) -> pointF_list.
        % get plottable points from datumXY/3, optionally sorting the list
clauses
    getXYpointF_list( ID, SortYN ) = PP :-
        PlottablePoints = [ P || datumXY(ID,X,Y), P = genXYpointF(X,Y) ],
        if SortYN = true then
                PP = sort( PlottablePoints )
            else
                PP = PlottablePoints
        end if.

/******************************************************************************
                PLOTTING ROUTINES
******************************************************************************/
predicates
    plotSeriesDatumXY : ( graphics, integer SeriesNum, real X, real Y ).
clauses
    plotSeriesDatumXY( G, SeriesNum, X,Y ):-
        Size = calcXYPointSize(),
        OffSet = convert( real32, Size / 2.0 ),
        PenBorder = chartDecoration::penNum(SeriesNum),
        BrushFill = chartDecoration::brushNum(SeriesNum),

        if Xp = tryScaleToAxisX(X) - OffSet
            and Yp = tryScaleToAxisY(Y) - OffSet then
                %-- draw Circles
                G:fillEllipseF( BrushFill, gdiplus::rectF( Xp,Yp,Size,Size )),
                PenBorder:dashStyle := dashStyleSolid,
                G:drawEllipseF( PenBorder, gdiplus::rectF( Xp,Yp,Size,Size ))
        end if.

predicates
    plotSeriesDatumAtCoord : ( graphics, integer SeriesNum, real32 XPos, real32 YPos ).
        % Plot a data point at the specified real32 coordinates using the attributes of the SeriesNum (color, line style)
clauses
    plotSeriesDatumAtCoord( G, SeriesNum, XPos32, YPos32 ):-
        Size = calcXYPointSize(),
        OffSet = convert( real32, Size / 2.0 ),
        Xp = XPos32 - Offset,
        Yp = YPos32 - Offset,
        PenBorder = chartDecoration::penNum(SeriesNum),
        PenBorder:dashStyle := dashStyleSolid, % don't want to draw the point with a dotted line, it looks ugly
        BrushFill = chartDecoration::brushNum(SeriesNum),
        G:fillEllipseF( BrushFill, gdiplus::rectF( Xp,Yp,Size,Size )),
        G:drawEllipseF( PenBorder, gdiplus::rectF( Xp,Yp,Size,Size )).

predicates
    drawSeriesDataLineXY : ( graphics, integer SeriesNum, string ID, boolean SortedTF ).
clauses
    drawSeriesDataLineXY( G, SeriesNum, ID, SortedTF ):-
        Pen = chartDecoration::penNum( SeriesNum ),
        PP = getXYpointF_list( ID, SortedTF ),
        if list::length(PP) > 0 then % drawLinesF/2 will throw an exception on empty list.
            G:drawLinesF(Pen,PP)
        end if.

/******************************************************************************
            DRAW THE DATA RECTANGLE AND GRID LINES

    The grid should be drawn BEFORE the data rectangle.
    If the Step for any Grid line is 0.0, then that grid is not drawn.

    drawDataGrid/1 should be called BEFORE drawing the points so
        that the points overlay the grid lines and axes
******************************************************************************/

predicates
    drawDataGrid : ( graphics, real MinorStepX, real MajorStepX, real MinorStepY, real MajorStepY ).
    drawDataGrid : ( graphics ).
clauses
    drawDataGrid( G ):-
        drawDataGrid(G, gridStepMinorX, gridStepMajorX, gridStepMinorY, gridStepMajorY ).

    drawDataGrid( G, MinorStepX, MajorStepX, MinorStepY, MajorStepY ):-
        drawGridLines( G, MinorStepX, MajorStepX, MinorStepY, MajorStepY ),
        drawDataRectangle( G ).

    drawDataRectangle( G ):-
        G:drawRectangleI( penDataAxes(), rectI( dataPxL,dataPxT, dataPxWidth, dataPxHeight ) ).

predicates
    drawGridLines : ( graphics, real MinorStepX, real MajorStepX, real MinorStepY, real MajorStepY ).
clauses
    drawGridLines( G, MinorStepX, MajorStepX, MinorStepY, MajorStepY ):-
        drawGridLinesVert( G, MinorStepX, gridStyleMinor ),
        drawGridLinesVert( G, MajorStepX, gridStyleMajor ),
        drawGridLinesHoriz( G, MinorStepY, gridStyleMinor ),
        drawGridLinesHoriz( G, MajorStepY, gridStyleMajor ).

            predicates
                drawGridLinesHoriz : ( graphics, real Step, gridStyleDom ).
            clauses
                drawGridLinesHoriz( _G, 0.0, _GridStyle ):- !.
                drawGridLinesHoriz( _G, Step, _ ):- Step > valueMaxY, !.
                drawGridLinesHoriz( G, Step, GridStyle ):-
                    if GridStyle = gridStyleMajor then P = penGridMajorH() else P = penGridMinorH() end if,
                    XL = convert( real32, dataPxL ),
                    XR = convert( real32, dataPxR ),
                    ValuesY = axisValuesY( Step ),
                    foreach Y = getMember_nd( ValuesY ) do
                        if Ypx = tryScaleToAxisY(Y) then
                            G:drawLineF( P, pointF( XL,Ypx ), pointF( XR, Ypx ) )
                        end if
                    end foreach.

            predicates
                drawGridLinesVert : ( graphics, real Step, gridStyleDom ).
            clauses
                drawGridLinesVert( _G, 0.0, _GridStyle ):- !.
                drawGridLinesVert( _G, Step, _ ):- Step > valueMaxX, !.
                drawGridLinesVert( G, Step, GridStyle ):-
                    if GridStyle = gridStyleMajor then P = penGridMajorV() else P = penGridMinorV() end if,
                    YT = convert( real32, dataPxT ),
                    YB = convert( real32, dataPxB ),
                    ValuesX = axisValuesX( Step ),
                    foreach X = getMember_nd( ValuesX ) do
                        if Xpx = tryScaleToAxisX(X) then
                            G:drawLineF( P, pointF(Xpx,YT ), pointF( Xpx, YB ) )
                        end if
        end foreach.

predicates
    drawAxisValuesX: ( graphics, real Step ).
        % NOTE: Does not advise user if there are so many steps that the labels are overwritten
    drawAxisValuesX : ( graphics ).
clauses
    drawAxisValuesX( G ):-
        drawAxisValuesX( G, gridStepMajorX ).

    drawAxisValuesX( _, 0.0 ):- !.
    drawAxisValuesX( _, Step ):- Step > valueMaxX, !.
    drawAxisValuesX( G, Step ):-
        %-- generate font for labelling axis values based on size of both X & Y labels
        YY = axisValuesY( Step ),
        FONT = chartDecoration::fontAxisLabelsXY( G, YY, axisDecimalsY, zone_rectF(zoneValuesX), zone_rectF(zoneValuesYL) ),

        XX = axisValuesX( Step ),
        BRUSH = brushValueText(),
        FS = chartDecoration::axisValueFormatDecimals( axisDecimalsX ),
        RctTop = dataPxB,
        foreach X = getMember_nd(XX) do
            ValueStr = trim(format( FS,X )),
%            G:measureString( ValueStr, some(FONT), trialRectF, none(), BoundBox, _CPts, _Lines ),
            G:measureString( ValueStr, FONT, trialRectF, stringFormat::create(),  BoundBox, _,_ ),   % HWP 2018-11-04 VIP 8 upgrade
            BoundBox = gdiplus::rectF(_,_,RctWidth,RctHeight),
            if RctLeft = tryScaleToAxisX( X ) then
                RCT = gdiplus::rectF( RctLeft - convert( real32, RctWidth/2.0), RctTop,RctWidth,RctHeight ),
                %-- RCT sized to string is centered under the X value so don't need to center string in rectangle
%                G:drawString( ValueStr, some(FONT), RCT, none(), some(BRUSH) )
                G:drawString( ValueStr, FONT, RCT, stringFormat::create(), BRUSH )   % HWP 2018-11-04 VIP 8 upgrade
%                G:drawRectangleF( penDefault(), RCT ) % enable for debugging
            end if
        end foreach.

predicates
    drawAxisValuesY : ( graphics, real Step ).
        % Does not draw if Step = 0.0 or if Step > valueMaxY
        % NOTE: Does not advise user if there are so many steps that the labels are overwritten
    drawAxisValuesY : ( graphics ).
clauses
    drawAxisValuesY( G ):-
        drawAxisValuesY( G, gridStepMajorY ).

    drawAxisValuesY( _, 0.0 ):- !.
    drawAxisValuesY( _, Step ):- Step > valueMaxY, !.
    drawAxisValuesY( G, Step ):-
        %-- generate font for labelling axis values based on size of both X & Y labels
        YY = axisValuesY( Step ),
        AdjFONT = chartDecoration::fontAxisLabelsXY( G, YY, axisDecimalsY, zone_rectF(zoneValuesX), zone_rectF(zoneValuesYL) ),

        %-- create stringFormat object for drawing values in graphics class
        DrawFmt = stringFormat::create(),
        DrawFmt:alignment := getZoneAlignH( zoneValuesYL ),
        DrawFmt:lineAlignment := getZoneAlignV( zoneValuesYL ),
        DrawFmt:formatFlags := stringFormatFlagsNoClip + stringFormatFlagsNoWrap,

        %-- define the rectangle parameters used to draw the value string
        ValueFmt = chartDecoration::axisValueFormatDecimals( axisDecimalsY ),   % retrieve format string for number of decimal places desired
%        G:measureString( format(ValueFmt,maximum(YY)), some(AdjFONT), trialRectF, none(), BoundRCT, _CPts, _Lines ),
        G:measureString( format(ValueFmt,maximum(YY)), AdjFONT, trialRectF, stringFormat::create(), BoundRCT, _CPts, _Lines ),   % HWP 2018-11-04 VIP 8 upgrade
        BoundRCT = gdiplus::rectF(_,_,RctWidth,RctHeight),
        RctLeft = dataPxL - RctWidth,
        HalfLeading = chartDecoration::fontLeadingPxHalf( AdjFONT ),

        %--  Displace DrawRCT down by 1/2 eading to vertically center the string on the Y-value (Mid)
        RctTop = {  ( YPos ) = YPos - convert( real32, RctHeight / 2 ) + HalfLeading
                },
        BRUSH = brushValueText(),
        foreach Y = getMember_nd(YY) do
            YString = trim( format(ValueFmt,Y) ),
            if LabelMid = tryScaleToAxisY( Y ) then   % only values in Y-axis range are plotted
                DrawRCT = gdiplus::rectF( RctLeft,  RctTop( LabelMid ), RctWidth, RctHeight ),
%                G:drawRectangleF( penDefault(), DrawRCT ), % enable for debugging
%                G:drawString( YString, some(AdjFONT), DrawRCT, some(DrawFmt), some(BRUSH) )
                G:drawString( YString, AdjFONT, DrawRCT, DrawFmt, BRUSH )   % HWP 2018-11-04 VIP 8 upgrade

            end if
        end foreach.

/******************************************************************************
                    C H A R T I N G   C L A U S E S
******************************************************************************/

    drawChartXY( G ):-
        drawDataGrid( G ),
        drawAxisValuesX( G ),
        drawAxisValuesY( G ),

        ShowLabelBordersTF = false, % set to true for testing/debugging
        drawLabels( G, [zoneLabelTitle,zoneLabelYL,zoneLabelYR,zoneLabelBottom], ShowLabelBordersTF ),

        % each series plots with its own colors and line style
        SeriesList = getDataXY_ID_list(),
        foreach Series = getMember_nd(SeriesList) do
            if SerNum = tryGetIndex(Series,SeriesList) then

                if doConnectPoints = true then
                    drawSeriesDataLineXY( G, SerNum, Series, true )  % draw lines first so plot overwrites lines
                end if,

                foreach datumXY(Series,X,Y) do
                    plotSeriesDatumXY(G,SerNum,X,Y)
                end foreach

            end if
        end foreach,

        drawLegend( G ).

/******************************************************************************
                    DRAW LEGEND

    STRATEGY:
        Get EM height
        For each data series,
            draw a DOT at point( fX, fY ) in the corresponding color
            write the NAME of the data series in the corresponding color.
        Set properties used to relocate the legend:
            legendOuterRectF set to bounding box of legend rectangle
            legendMoveMode set to false

******************************************************************************/

clauses
    isPointInLegend( PntVPI ):-
        isPNT_in_rectF( PntVPI, legendOuterRectF ).

predicates
    drawLegend : ( graphics ).
clauses
    drawLegend( G ):-
        % Greate the legend font sized as fraction of dataZone height,
        % which is needed for font scaling when resizing chart window.
        MaxLegendLines = 20,
        LegHeightWant = trunc( dataPxHeight * (1/MaxLegendLines) ),
        FONT = fontLabelFitHeight_EM( G, "M", fontDefault(), LegHeightWant ),

        font_EM_size( G,FONT, EmW,EmH ), % NOTE: FONT:getHeight(G) does NOT include leading
        LegInsetX = round( legendInsetRatioX * zone_Wr32(zoneData) ),
        LegInsetY = round( legendInsetRatioY * zone_Hr32(zoneData) ),

        DrawFMT = stringFormat::create(),
        DrawFMT:alignment := stringAlignmentNear,
        DrawFMT:formatFlags := stringFormatFlagsNoClip + stringFormatFlagsNoWrap,

        %-- Generate a brush of the color corresponding to the data series index.
        IndexedBrush = { (Index) = BRUSH :-
            PEN = rctPenDefault(),
            PEN:color := color::create( chartDecoration::penNumColor( Index ) ),
            BRUSH = PEN:brush
            },

        % Generate the vertical location of the legend string to be drawn based on the label index (0..N).
        % Legend drawing rectangle coordinates are based on the Left,Top position of zoneData rectangle.
        gdiplus::rectF( X,Y,_,_) = zone_rectF( zoneData ),
        IndexedYPos = { (Index) = YP :-
            YP = convert( real32, (Y + (Index * EmH )) + LegInsetY )
            },

        % Draw the legend strings and accumlate the legend string rectangles
        % which are used to define a bounding rectangle for the entire legend.
        % This is used to detect if a mouse-click PNT is in the legend rectangle when relocating the legend.
        LegRects = varM::new([]),
        foreach LegStr = getMember_nd( getDataXY_ID_list() )
            and INDEX = tryGetIndex(LegStr, getDataXY_ID_list() ) do

                % create a drawing rectangle and draw the legend label string in it
%                G:measureString( LegStr, some(FONT), trialRectF, some(DrawFMT), BOX, _,_ ),
                G:measureString( LegStr, FONT, trialRectF, DrawFMT, BOX, _,_ ),   % HWP 2018-11-04 VIP 8 upgrade
                BOX = gdiplus::rectF(_,_,W,_),
                RectF = gdiplus::rectF( pointF( X+LegInsetX, IndexedYPos(INDEX) ), sizeF( W, EmH ) ),
                LegRects:value := [RectF|LegRects:value],

%                G:drawString( LegStr, some(FONT), RectF, some(DrawFMT), some(IndexedBrush(INDEX)) ),
                G:drawString( LegStr, FONT, RectF, DrawFMT, IndexedBrush(INDEX) ),   % HWP 2018-11-04 VIP 8 upgrade
                % put the indexed series marker in front of this label string
                plotSeriesDatumAtCoord( G, INDEX, X + LegInsetX - EmW/2, IndexedYPos(INDEX) + EmH/2 )
        end foreach,

        % Generate outer bounding box for legend (including sample dots) to use when interactively relocating the legend
        % Set property for legendOuterRectangle
        if LegRects:value = [ gdiplus::rectF( LegL,_T,_W,LegH ) | _ ] then  % left positions and heights are all the same, so just pick the first
                LegT = minimum( [ TOP || E = getMember_nd( LegRects:value ), E = gdiplus::rectF(_,TOP,_,_) ] ),
                LegW = maximum( [ WIDTH || E = getMember_nd( LegRects:value ), E = gdiplus::rectF(_,_,WIDTH,_)] ),
                N = list::length( LegRects:value ),
                LR = gdiplus::rectF( LegL- EmW, LegT, LegW + EmW + EmW, LegH * N ),
                G:drawRectangleF( rctPenDefault(), LR ),
                legendOuterRectF := LR
            else
                legendOuterRectF := gdiplus::rectF(0,0,0,0)
        end if,

        legendMoveMode := false. % used when moving the legend; the initial mode is NOT MOVING.

end implement chart