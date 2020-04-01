/******************************************************************************
Author:       	Harrison Pratt
File:         	chartIO.cl
Project:

Package:		chart_PACK
Created:      	2017-07-20
Modified:

Purpose:      	Acquires data for chart object to read,
					either directly from the application
					or by reading data from CSV file.

Comments:     CSV is CHARACTER-separated, not only comma-separated.
				Current separation characters are ',', '\t' and '|'.
				Modify csvSplitter in chartIO.pro to add more separation characters.

Data file format:

    LABELS:  First line is a tab-separated line containing 1...10 alphanumeric strings, NOT quoted
    e.g. Column 1 <tab> Column 2 ... <tab> Column N
    DATA:  Remaining lines are tab-separated lines contining real numbers
    e.g. 12.3 <tab> 4.56 ... <tab> 888.999

    If any data line has fewer or more data elements than the Label line,
    then an error message is displayed in the Messages window
    and that data line IS NOT PROCESSED.

    NOTE: if you want to extend the supported data formats beyond {X,Y}
        to, say, {Label,ValueReal} then this is where you should start
        adding code to parse and store data.
******************************************************************************/

class chartIO
    open core

domains

    chartRealDom =
        r(real);
        nil. % 'nil' is used to represent missing data
    chartRealDom_list = chartRealDom*.

predicates

    %-- reading data from files

    clearSXY : ().
    % Empty the database BEFORE loading data

    readFileDataXY : (string QFN).
    % Reads the data from a tab-separated file into the Chart database
    % NOTE: Call clearSXY/0 to empty the database BEFORE loading of data, loads data

    putSXY : (string ColumnLabel, real ValueX, real ValueY).
    % use this from application to store data to chart

    getSXY_nd : (string ColumnLabel, real ValueX, real ValueY) nondeterm (o,o,o) (i,o,o).
    % used by chart to retrieve data

end class chartIO
