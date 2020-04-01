% Copyright 2017 Harrison Pratt

implement appData_to_Chart
    open core

clauses
/*
    NOTE: This class is only for demonstration purposes and is not needed for use of the Chart_PACK
*/

    putSomeDataInChart() :-
        % HOWTO put some data into a chart directly from your application

        chartIO::clearSXY(), % empty the chartIO database

        %-- store your data in chartIO class

        chartIO::putSXY("Column01", 3, 4),
        chartIO::putSXY("Column02", 11, 12),
        chartIO::putSXY("Column01", 5, 6),
        chartIO::putSXY("Column02", 17, 18),
        chartIO::putSXY("Column01", 20, 25).

end implement appData_to_Chart
