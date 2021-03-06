﻿% Copyright 2020 Harrison Pratt

class taskWindow : taskWindow

constructors
    new : ().

constants
    % HOWTO since #stringinclude is not supported in VIP 8x we can get the start up message by putting it here.
    startUpMsg8 : string =
"Application name:   TicTackToeN

What:               Play TicTacToe with a board size of your choosing.

Why:                A little demonstration app testing Vip 9x installation, with some hints for new VIP developers.

How to play:        Select game size by clicking a number or 'N' on the toolbar.
                    LEFT CLICK on the board to place your marker.
                    The current player is indicated in the game title.
                    RIGHT CLICK on the game board to display how many ways you can win using a cell.
                    Touch screen play works. Tap once for left click, press and hold for right click.

How to win:         Place your markers in a row, column or diagonal line.
                        The number of contiguous markers to win is:
                            If board size = 3   you need 3 contiguous markers to win.
                            If board size > 3   you need N-1 contiguous markers where N = board size (across or down)

What does this program demonstrate in the project code?

    How to handle getting a return value from dialog.
    GDI+ usage with dynamic scaling of window graphics on resizing of the window.
    Use of 2-dimensional array (array2M) for handling game play.
    Anonymous predicate usage.
    Modify Messages window font and number of lines retained in buffer.
    Pluralizing text messages

    HOWTO find hints:

        Search for 'HOWTO' in the VIP IDE by pressing Ctrl-Shift-F to search the project files for programming hints.".

end class taskWindow
