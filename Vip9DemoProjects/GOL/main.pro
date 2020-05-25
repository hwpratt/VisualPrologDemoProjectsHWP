% Harrison Pratt 2020

implement main

clauses
    run() :-
        TaskWindow = taskWindow::new(),
        GdipToken = gdiplus::startUp(), % add this line to start up GDIPLUS when the application starts
        TaskWindow:show(),
        gdiplus::shutDown(GdipToken).  % and add this line to shut down GDIPLUS on exit

end implement main

goal
    mainExe::run(main::run).
