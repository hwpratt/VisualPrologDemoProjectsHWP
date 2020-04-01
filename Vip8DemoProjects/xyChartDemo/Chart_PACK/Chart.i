% Copyright 2017 Harrison Pratt

interface chart supports chart_core
    open core, gdiplus, vpiDomains

domains

    %-- for XY plots
    xyDatum_Dom = xy( real X, real Y ).
    xyDatumList_Dom = xyDatum_Dom*.

predicates

    drawDataRectangle : ( graphics ).
    drawChartXY : ( graphics ).

predicates  %-- data input to graph

    %-- BIVARIATE DATA HANDLING.
    %-- Bivariate data is labelled with a string ID to support multiple data series plotted on the same graph.

    clearDataXY : ( string ID ).   % Retract all XY data from set with label ID.
    clearDataXY : ().              % Retract all XY data from all data sets.
    readDataXY_fromIO : ().

    putDatumXY : ( string ID, xyDatum_Dom ). % asserts one named xy fact
    putDataListXY : ( string ID, xyDatumList_Dom ) . % assert a series of xy named facts

    %-- setDataDisplayRange/2 sets the display ranges for the data
        % Values outside this range are NOT displayed in the graph
    setDataDisplayRangeX : ( real MinX, real MaxX ).
    setDataDisplayRangeY : ( real MinY, real MaxY ).

    setLabelsLTRB : ( string LabelL, string LabelT, string LabelR, string LabelB ).
        % Labels are axis and chart labels, NOT tic values
        % You can also set these individually with labelXXX := SomeString.
        % The default label values are ""

    setDataDisplayRangesXY : ( real MinX, real MaxX, real MinY, real MaxY ).

    updatePropertiesXY : ().

    %-- legend management

    isPointInLegend : ( vpiDomains::pnt ) determ.

end interface chart