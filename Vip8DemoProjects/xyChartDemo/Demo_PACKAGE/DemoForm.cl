/******************************************************************************
Author:       Harrison Pratt

File:         demoForm.cl
Project:

Package: 		Demo_PACKAGE
Created:      2017-07-27
Modified:

Purpose:      Simple form to demonstrate how to use the chart class.
Comments:

******************************************************************************/

class demoForm : demoForm
    open core

predicates

    display : (window Parent) -> demoForm DemoForm.

    display : ( window Parent, string TitleText ) -> demoForm DemoForm.

constructors
    new : (window Parent).

end class demoForm