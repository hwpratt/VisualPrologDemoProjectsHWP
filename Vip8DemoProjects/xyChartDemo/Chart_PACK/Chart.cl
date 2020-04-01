/******************************************************************************
Author:       	Harrison Pratt
File:         	Chart.cl
Project:
Package:     	Chart_PACK
Created:     	2017-03-31
Modified:
Purpose:      	Base class for chart drawing
Comments:
******************************************************************************/

class chart : chart
    open core
    [noDefaultConstructor]

constructors

    new : ( string Name ).
        % Creates the named chart object on form creation.
        % Name is case-insensitive in this application
        % Name is used to register the chart object in the chart class database
        % HINT: use the form or dialog class name for Name.  That way, you can dispose of specific form registry entries

predicates

    getChartNamed : ( string NameCI ) -> chart determ.  % get chart object by Name from the class registry

    deregisterChartNamed : ( string NameCI ). % remove all registered objects with NameCI (case-insensitive match)

end class chart