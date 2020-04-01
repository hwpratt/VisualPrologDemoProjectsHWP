% Copyright 2017 Harrison Pratt

implement main
    open core

clauses
    run() :-   % HOWTO start and shut down GDIPLUS in your application

        TaskWindow = taskWindow::new(),
        GdipToken = gdiplus::startUp(),  % add this line to start up GDIPLUS when the application starts
        TaskWindow:show(),
        gdiplus::shutDown(GdipToken). % and add this line to shut down GDIPLUS on exit

end implement main

goal
    mainExe::run(main::run).