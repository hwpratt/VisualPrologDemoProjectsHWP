/******************************************************************************
Author:     Harrison Pratt    

File:       chartPropertyEditor.cl
Project:     

Package: 	chart_PACK
Created:    2017-07-27
Modified:    

Purpose:    Opens chartPropertyEditor dialog to modify chart display properties
Comments:   Optionally saves & recalls last saved properties.

******************************************************************************/

class chartPropertyEditor : chartPropertyEditor
    open core

predicates

    display : ( window Parent, chart ) -> chartPropertyEditor.

constructors

    new : ( window Parent, chart ).

end class chartPropertyEditor