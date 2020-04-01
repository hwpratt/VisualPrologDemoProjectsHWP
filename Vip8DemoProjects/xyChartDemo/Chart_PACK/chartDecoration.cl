/******************************************************************************
Author:        Harrison Pratt
File:          chartDecoration.cl
Project:
Package:		chart_PACK
Created:		2017-07-20
Modified:
Purpose:       	Manages display attributes for pens, brushes, etc.
Comments:
				This is where you can define default colors, line-widths, line-styles, etc.

Notes:
				FONT STYLES in gdiPlus_native
					fontStyleRegular = 0.
					fontStyleBold = 1.
					fontStyleItalic = 2.
					fontStyleBoldItalic = 3.
					fontStyleUnderline = 4.
					fontStyleStrikeout = 8.

******************************************************************************/

class chartDecoration
    open core

constants

    trialRectF : gdiplus::rectF = gdiplus::rectF(0,0,90000,90000).
        % arbitrary huge rectangle used for measuring text when don't care about wrapping, etc.

predicates
	%-- fontXXX returns font to be use for XXX (e.g., Title, Value display, Axis Labels)
    fontTitleScaled_EM : ( gdiplus::rectF ) -> font.  % Top center title of chart
    fontValueScaled_EM : ( gdiplus::rectF ) -> font. % Values for X,Y axes
%    fontValueScaled_StrY : ( graphics, string, gdiplus::rectF, gdiplus::rectF ) -> font. % Values for Y axis

    fontAxisLabelsXY : ( graphics, real_list ValuesYY, integer DecimalsY, gdiplus::rectF, gdiplus::rectF ) -> font.
		% Return a font scaled for BOTH X & Y value displays
		% The font is the minimum size needed to display both value sets
		% 	within their respective value rectangles.

    fontLabelScaled_EM : ( gdiplus::rectF ) -> font.
    fontLabelFitRectF_EM : ( graphics, string StrToFit, font CurrFont, gdiplus::rectF ) -> font.
    fontLabelFitRectFVertical_EM : ( graphics, string StrToFit, font CurrFont, gdiplus::rectF ) -> font.
    fontLabelFitWidth_EM : ( graphics, string LongestStr, font CurrFont, integer WidthR ) -> font.
    fontLabelFitHeight_EM : ( graphics, string LongestStr, font CurrFont, integer HeightR ) -> font.
    font_EM_size : ( graphics, font CurrFont, integer Width [out], integer Height [out] ).

    emSizeToFitWidth : ( graphics, string, font CurrFont, integer WidthAvail ) -> real EmSizeNeeded.
    emSizeToFitHeight : ( graphics, string, font CurrFont, integer HeightAvail ) -> real EmSizeNeeded.

    fontLeadingPx : ( font ) -> real32.  % height of font leading in pixels
    fontLeadingPxHalf : ( font ) -> real32. % half of font leading in pixels

    verticalStr : ( string ) -> string StrWithEmbeddedNLs. % use for drawing vertical text of labels
    explodedStr : ( string ) -> string StrWithEmbeddedSpaces. % may use to expand a Title string for display

    rctPenDefault : () -> pen.  % the pen used when you don't care, mostly for debugging
    % rctPenDataRct : () -> pen.  % the pen for drawing the data plotting rectangle
    penGrid : () -> pen. % for drawing H & V grid lines
    penGridMajorH : () -> pen.
    penGridMajorV : () -> pen.
    penGridMinorH : () -> pen.
    penGridMinorV : () -> pen.
    penDataAxes : () -> pen.

    %-- pen and brush used for drawing axis Values

    penValueText : () -> pen.
    brushValueText : () -> brush.

    %-- fonts used for drawing axis Values and Labels
    fontDefault : () -> font.
    fontValues : () -> font.
    fontLabels : () -> font.

    %-- indexed pens and brushs, indexed by data series (column) number, 0-based index

    penNum : ( integer PenNum ) -> pen.
    brushNum : ( integer BrushNum ) -> brush.
    penNumList : () -> integer_list.
    brushNumList : () -> integer_list.
    penDefault : () -> pen.
    brushDefault : () -> brush.

    %-- lookup pen or brush attributes without creating a pen first

    penNumWidth : ( integer PenNum ) -> real.
    penNumColor : ( integer PenNum ) -> unsigned.

    brushNumWidth : ( integer BrushNum ) -> real.
    brushNumColor : ( integer BrushNum ) -> unsigned.

    %-- format axis values (not the labels)

    axisValueFormatDecimals : (  integer Decimals ) -> string FormatString.
		% This is used in string::format/2 for displaying values.
		% It is NOT the drawString format which is about centering and wrapping.

    maxDrawWidthReals : ( graphics, font, real_list, string FormatString ) -> real32.
        % This is specific to the Chart application and looks at a set of real numbers
        % Use when creating a font that needs to be scaled to a certain size.

    maxDrawWidthStrings : ( graphics, font, string_list ) -> real32.

    %-- TEST PREDICATES

    showPenAndBrushColors : ( graphics ).
        % a test predicate to show the numbered brushes and pens in a window

end class chartDecoration