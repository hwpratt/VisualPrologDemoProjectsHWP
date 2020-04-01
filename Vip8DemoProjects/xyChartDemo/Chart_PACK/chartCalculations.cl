/******************************************************************************
Author:       	Harrison Pratt
File:         	ChartCalculations.cl
Project:
Package:     	Chart_PACK
Created:     	2017-07-20
Modified:
Purpose:      	Chart object calculations which do NOT access Chart properties.
                These are not specific to Chart calculations.
Comments:	    NOTE: CALCULATIONS using Chart PROPERTIES are implemented in Chart_Core.
******************************************************************************/

class chartCalculations

    open core

domains

    real32_list = real32*.

predicates

    realMinMax : ( real_list ) -> tuple { real Minimum, real Maximum } determ.
    realMinMax : ( real32_list ) -> tuple { real32 Minimum, real32 Maximum } determ.
        % FAILs on empty list

    realFromToStep : (real From, real To, real Step) -> real R nondeterm.
    realFromToStep : (real32 From, real32 To, real32 Step) -> real32 R nondeterm.
        % see std::fromToInStep/3

    realsFromToStep : ( real From, real To, real Step ) -> real_list.
    realsFromToStep : ( real32 From, real32 To, real32 Step ) -> real_list.

    reals_reals32 : ( real_list ) -> real32_list.
    reals32_reals : ( real32_list ) -> real_list.

    longestStr : ( string_list ) -> string.  % returns "" on empty list

    isPNT_in_rectF : ( vpiDomains::pnt, gdiplus::rectF ) determ.
        % Note: Window event handlers use VPI PNT and GDI+ uses point and rectF

end class chartCalculations