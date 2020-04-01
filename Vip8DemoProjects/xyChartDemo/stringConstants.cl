% Copyright 2018 Harrison Pratt

class stringConstants

    open core

constants

    howToUseChartPackMsg =

@"HOW TO USE CODE IN YOUR OWN PROJECT:

Copy the Chart_PACK package into your own project.

This should give you all that you need to get started.
You shouldn't need anything in the GDIPLus_Tolls package for routine use.

You will need to write your own code to put data into the chartIO class
and to select files to read/write appropriate to your application.
".

    dataFileFormatMsg =

@"DATA FILE FORMAT

The data file format is ANSI character-separated, not just comma-separated.
The separation characters may be comma (,), tab('\t') or pipe (|) characters.
You may modify the CONSTANT csvSplitter in chartIO.pro to add more separation characters.

The program requires one line of character-separated labels,
followed by one or more lines of character-separated real or integer numbers.
Labelled data lines such as might be used for pie charts or histograms are not supported.

    LABELS:  First line is a tab-separated line containing 1...10 alphanumeric strings, NOT quoted
    e.g. Column 1 <tab> Column 2 ... <tab> Column N
    DATA:  Remaining lines are tab-separated lines contining real numbers
    e.g. 12.3 <tab> 4.56 ... <tab> 888.999

    If any data line has fewer or more data elements than the Label line,
    then an error message is displayed in the Messages window and that data line IS NOT PROCESSED.

SAMPLE DATA FILE LINES (invisible tab shown as '<tab>':

Hours<tab>Heading<tab>Speed<tab>Inferred WindDir
0.01<tab>230<tab>5.76<tab>277
0.02<tab>231<tab>5.84<tab>278
0.03<tab>229<tab>5.56<tab>276
0.04<tab>223<tab>6.06<tab>270
0.05<tab>225<tab>6.08<tab>272
...
    ".

    startupMsg =

@"xyCHARTDEMO - for VIP 8.0 				2018-11-08 Harrison Pratt
-----------------------------------------------------------------
Open one or two sample XY charts from the TaskWindow menu:

    Chart > Draw from Application (F9)
    - and/or -
    Chart > Draw from file (F10)

    * Right-click in the chart form to open the chart Property Editor
            This will allow you to change scaling, grid intervals, labelling, etc.
    * You can have both charts open at the same time.
		They will overlay each other, so drag the top one aside.

    * To move the Legend, Ctrl-LeftClick in the legend and then click a new location.

    * To save the chart image to the clipboard or a file, press Alt-C

You can view/edit the chart data file using Notepad:

    Chart > Edit data file with Notepad

Charts may have up to 10 series (columns of data), each with its own drawing attributes.
    To see the pen and brush attributes for different series, select

        Chart > Show drawing attributes (F11)

To see how to implement the Chart_PACK in your application

	* Do 'Find in Files' (Ctrl-Shift-F) in the VIP IDE and search for 'HOWTO'.
    * Click Help -> How to use this code in this demo program".

end class stringConstants
