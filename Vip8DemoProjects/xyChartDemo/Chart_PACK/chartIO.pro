% Copyright 2017 Harrison Pratt

implement chartIO

    open core, file, filename, inputStream, inputStream_file, list, std, string, vpiCommonDialogs

constants

    csvSplitter : string = "\t,|".
    % CHARACTER-SEPARATED splitter, can split character-separated file on tab, comma or pipe
    % Add other characters to csvSplitter to use other separators in file (e.g., '|")

/******************************************************************************
	DATABSE MANAGEMENT CLAUSES
******************************************************************************/

class facts - xyDataDB

    %-- initial input of chart data from flat file
    dataLabels : string_list := []. % column labels

    xyValues : (chartRealDom_list). % temporary values created when reading file

    %-- data is transformed into sxy/3 for simple access when charting
    sxy : (string ColumnLabel, real, real). % series-labelled x,y data points used by CHART object.

class predicates
    assert_SXY_facts : ().
    % creates sxy/3 facts from xyValues/1 facts and adds data labels to dataLabels fact.
clauses
    assert_SXY_facts() :-
        MaxColumIndex = list::length(dataLabels) - 1, % the first column is an X value
        foreach COLUMN = std::fromTo(1, MaxColumIndex) do
            % NOTE: skips the X value in index 0
            foreach xyValues(RowValues) do
                % ROW
                if [r(X) | _] = RowValues and r(Y) = tryGetNth(COLUMN, RowValues) and ID = tryGetNth(COLUMN, dataLabels) then
                    putSXY(ID, X, Y)
                else
                    stdio::writef("\nERROR in % processing xyValues(%)", predicate_fullname(), toString(RowValues))
                end if
            end foreach % ROW
        end foreach, % COLUMN
        !.

    putSXY(ID, X, Y) :-
        assert(sxy(ID, X, Y)),
        if not(isMember(ID, dataLabels)) then
            dataLabels := [ID | dataLabels]
        end if.

    clearSXY() :-
        retractFactDb(xyDataDB).

    getSXY_nd(S, X, Y) :-
        sxy(S, X, Y).

/******************************************************************************
                    READ DATA FROM FILE
******************************************************************************/

    readFileDataXY(PathName) :-
        if file::existExactFile(PathName) then
            clearSXY(),
            xyLoadFileData(PathName),
            assert_SXY_facts()
        else
            vpiCommonDialogs::error(predicate_fullname(), concat("No such file:\n\n", PathName))
        end if.

class predicates
    xyLoadFileData : (string PathName_NoExt). % NOTE: advises but does not fail on errors
clauses
    xyLoadFileData(PathName) :-
        IS = inputStream_file::openFile8(PathName),
        %-- Read labels from first row of file
        LabelStr = IS:readLine(),
        if not(hasAnyAlphaChars(LabelStr)) then
            error(concat("ERROR in ", predicate_fullname()),
                concat("Invalid data labels: ", LabelStr, "\n\n", "Labels must contain at least 1 letter."))
        end if,
        dataLabels := string::split(LabelStr, csvSplitter),
        LabelCount = list::length(dataLabels),
        if LabelCount = 0 then
            % dataLabels will be [], advise user of error reading file
            error(concat("ERROR in ", predicate_fullname()), concat("Invalid data labels: ", toString(dataLabels)))
        end if,
        %-- read the rest of the file for real x,y data
        try
            foreach
                IS:repeatToEndOfStream() and DataStr = IS:readLine() and hasAnyRealChars(DataStr)
                and % ignore lines without at least some real data
                ValueSS = take(LabelCount, string::split(DataStr, csvSplitter))
                and % ignore extra columns of unlabelled data (should never happen)
                if list::length(ValueSS) <> LabelCount then
                    stdio::write("\nUnexpected column count in row data: ", ValueSS),
                    fail
                end if
            do
                ValueRR = ss_to_xyDomList(ValueSS),
                assert(xyValues(ValueRR))
            end foreach
        finally
            IS:close()
        end try.

class predicates
    hasAnyRealChars : (string) determ. % one or more characters forming real numbers
clauses
    hasAnyRealChars(S) :-
        Cx = fromTo(0, string::length(S) - 1),
        _ = searchChar("0123456789.-", subChar(S, Cx)),
        !.

class predicates
    hasAnyAlphaChars : (string) determ. % one or more letters
clauses
    hasAnyAlphaChars(S) :-
        Cx = fromTo(0, string::length(S) - 1),
        hasAlpha(subString(S, Cx, 1)),
        !.

class predicates
    ss_to_xyDomList : (string_list) -> chartRealDom_list.
    % NOTE: empty data strings are encoded as nil
clauses
    ss_to_xyDomList(SS) = RR :-
        RR =
            [ R ||
                S = getMember_nd(SS),
                if R = r(tryToTerm(real, S)) then
                elseif S = "" then
                    R = nil % datum is stored as 'nil' and is NOT SKIPPED by failure of conversion to real
                else
                    stdio::write("\n", predicate_fullname(), " ERROR converting ", S, " to real number"),
                    R = nil
                end if
            ].

end implement chartIO
