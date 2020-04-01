% Copyright 2017 Harrison Pratt

implement chartDataEditor
    open core, file, string, useExe, vpiCommonDialogs

constants

    ronsEditorQFN = @"C:\Program Files (x86)\Rons Place Apps\Rons Editor\Editor.WinGUI.exe".
    % download Ron's Editor here:   https://www.ronsplace.eu/products/ronseditor
    %-- command line switches for presence/absence of file column labels
    ronsColHeadersYes = "/HEAD:yes".
    % ronsColHeadersNo  = "/HEAD:no".

clauses
    editChartDataWithRonsEditor( QFN ) :-
        if not ( existExactFile( ronsEditorQFN ) ) then
                error( predicate_fullname(), "Ron's Editor is not installed.\n\nEdit chart data with Notepad." )
            else
                EditFile = { (S) :-
                    FmsStr = "\"%\" \"%\" %",  % file names precede switches
                    Cmd = string::format(FmsStr, ronsEditorQFN, S, ronsColHeadersYes ),
                    Exe = useExe::new( Cmd ),
                    Exe:run()
                    },
                if existExactFile(QFN) then
                        EditFile( QFN )
                    elseif resp_default = ask( predicate_fullname(), concat( "Create new file: ", QFN ), ["Create File","Cancel"] ) then
                        %-- create a blank file
                        OS = outputStream_file::create8(QFN),
                        OS:write( "X\tColumn_1\tColumn_2\tColumn_3\tColumn_4\n"), % add some dummy column headers
                        OS:close(),
                        EditFile( QFN )
                end if
            end if.

    editChartDataWithNotepad( QFN ):-
        EditFile = { (S) :-
            Cmd = string::format( "Notepad \"%\"", S ),
            Exe = useExe::new( Cmd ),
            Exe:run()
            },
        if existExactFile(QFN) then
                EditFile(QFN)
            else
                if resp_default = ask( predicate_fullname(),
                        concat( "Create new file: ", QFN ), ["Create File","Cancel"] ) then
                    OS = outputStream_file::create8(QFN),
                    OS:close(),
                    EditFile(QFN)
                end if
        end if.

end implement chartDataEditor