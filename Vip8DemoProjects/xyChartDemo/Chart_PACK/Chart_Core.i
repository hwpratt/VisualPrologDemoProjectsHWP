/******************************************************************************
Author:       	Harrison Pratt
File:         	Chart_Core.
Project:
Package:     	Chart_PACK
Created:     	2017-07-20
Modified:
Purpose:      	Base class for chart drawing
Comments:		Contains constants, domains, properties and calculations
				for Chart objects.

                This may be modified to change global chart layout parameters
                    such as zone spacing, data graphic area specification, etc.

				These calculations make use of the Chart properties;
					ones which do NOT are in the ChartCalculations class.
******************************************************************************/

interface chart_Core

    open core, gdiplus

constants

    %-- insetXXXAreaFraction is in range of 0.0 - 0.5
    insetDataAreaFraction : real = 0.10. % inside this is the data graphing area
    insetGraphAreaFraction : real = 0.01. % outside this is a plain unused border

    %-- gap between zones in pixels
    zoneGapPxX : integer = 2.
    zoneGapPxY : integer = 2.

domains
    zoneDom =
        zoneDrawing;
        % everything outside this is just unused border
        zoneData;
        % the rectangle in which the data is graphed
        zoneLabelTitle;
        % full-height between zoneDrawing & zoneData
        zoneLabelBottom;
        % half-height, below  zoneValuesX & zoneDr
        zoneValuesX; zoneValuesYL; zoneLabelYL; zoneValuesYR; zoneLabelYR.

    zoneDom_list = zoneDom*.

    gridStyleDom = gridStyleMajor; gridStyleMinor.

%    pointF_list = gdiplus::pointF*.

domains

    zoneTextOrient_HV_Dom = zTextOrient_H; zTextOrient_V; zTextOrient_NA.

    zoneRectLineWidth = integer.
    zoneRectLineColor = unsigned.
    zoneRectFillColor = unsigned.

properties

    %-- chart drawing options
    doConnectPoints : boolean.
    % If TRUE then the points are connected when the XY chart is drawn.

    %-- dimensions of the data rectangle in Pixels
    dataPxL : integer.
    dataPxT : integer.
    dataPxR : integer.
    dataPxB : integer.
    dataPxHeight : integer.
    dataPxWidth : integer.

    %-- dimensions of the drawing area in Pixels within the client window
    %-- These define a rectangle inset from the client window by insetGraphAreaFraction.
    %-- This rectangle is smaller than (or the same size) as the client window.
    drawPxL : integer.
    drawPxT : integer.
    drawPxR : integer.
    drawPxB : integer.
    drawPxHeight : integer.
    drawPxWidth : integer.

    %-- scaling related properties
    axisPixelsRealX : real.
    axisPixelsRealY : real.
    valueMaxX : real.
    valueMaxY : real.
    valueMinX : real.
    valueMinY : real.
    valueRangeX : real.
    valueRangeY : real.

    %-- format decimal places for axis value labels
    axisDecimalsX : integer.
    axisDecimalsY : integer.

    %-- graph labels
    labelLeft : string.
    labelTitle : string.
    labelRight : string.
    labelBottom : string.

    %-- increments for drawing gridlines and axis values.  If <> 0.0 then draw gridlines and values.  Default = 0.0
    gridStepMajorX : real.
    gridStepMinorX : real.
    gridStepMajorY : real.
    gridStepMinorY : real.

    %-- Initial Legend position is near the left, top of dataZone rectangle.
    %-- Change these insetRatio properties to relocate the legend on the graph
    %-- Legend repositioning is based on the L,T point of legendOutRectF
    legendInsetRatioX : real.
    legendInsetRatioY : real.
    legendOuterRectF : gdiplus::rectF. % The bounding rectangle surrounding the legend strings and Dots
    legendMoveMode : boolean. % a toggle used to control interactive Legend relocation

predicates % for calculations using zone dimensions

    zone_LTRB : (zoneDom) -> tuple{integer, integer, integer, integer}.
    zone_LTWH : (zoneDom) -> tuple{integer, integer, integer, integer}.
    zone_rectI : (zoneDom) -> gdiplus::rectI.
    zone_rectF : (zoneDom) -> gdiplus::rectF.
    zone_WHr32 : (zoneDom) -> tuple{real32 PixelsW, real32 PixelsH}.
    zone_Hr32 : (zoneDom) -> real32 PixelsH.
    zone_Wr32 : (zonedom) -> real32 PixelsW.

predicates

    getZoneAlignH : (zoneDom) -> gdiplus_native::stringAlignment.
    getZoneAlignV : (zoneDom) -> gdiplus_native::stringAlignment.
    getZoneOrientationHV : (zoneDom) -> zoneTextOrient_HV_Dom.

    scaleChartToWIndow : (window ToRedrawOnPaint).
    % Gets the client window size and SETS PROPERTIES defining the DrawingArea and the DataArea.
    % Adjusts PROPERTIES used to scale all drawing operations which must be adjusted each time the client window is resized.
    % This predicate must be called in the onPaint event handler before any drawing takes place.
    % This does not do any data value scaling; that is done when data is stored in the Chart object.

predicates

    isInRangeX : (real) determ.
    isInRangeY : (real) determ.

    tryScaleToAxisX : (real) -> real32 PointToPlotX determ.
    tryScaleToAxisY : (real) -> real32 PointToPlotY determ.

    axisValuesY : (real Step) -> real_list AxisLabelValuesStepped.
    % Return list of real numbers used for labelling or drawing grid lines of the Y axis

    axisValuesX : (real Step) -> real_list AxisLabelValuesStepped.
    % Return list of real numbers used for labelling or drawing grid lines of the X axis

    calcXYPointSize : () -> real32. % adjusts size of point plotted when form size changes

    genXYpointF : (real X, real Y) -> gdiplus::pointF PixelsXY determ.

    insetRatio_fromPNT : (vpiDomains::pnt VpiPoint, chart ChartWithDataRectangle) -> tuple{real IrX, real IrY}.
    % Calculate and return the fraction inset of a vpi::PNT in the DataR ectangle of a chart.
    % This is used only for Legend placement

end interface chart_Core