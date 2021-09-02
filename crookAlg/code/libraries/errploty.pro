; $Id: errplot.pro,v 1.12 2001/01/15 22:28:03 scottm Exp $
;
; Copyright (c) 1983-2001, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;

PRO ErrPlotY, X, Low, High, WIDTH=width, COLOR=col
;+
; NAME:
;	ERRPLOT
;
; PURPOSE:
;	Plot error bars over a previously drawn plot.
;
; CATEGORY:
;	J6 - plotting, graphics, one dimensional.
;
; CALLING SEQUENCE:
;	ERRPLOT, Low, High	;X axis = point number.
;
;	ERRPLOT, X, Low, High	;To explicitly specify abscissae.
;
; INPUTS:
;	Low:	A vector of lower estimates, equal to data - error.
;	High:	A vector of upper estimates, equal to data + error.
;
; OPTIONAL INPUT PARAMETERS:
;	X:	A vector containing the abscissae.
;
; KEYWORD Parameters:
;	WIDTH:	The width of the error bars, in units of the width of
;	the plot area.  The default is 1% of plot width.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	An overplot is produced.
;
; RESTRICTIONS:
;	Logarithmic restriction removed.
;
; PROCEDURE:
;	Error bars are drawn for each element.
;
; EXAMPLES:
;	To plot symmetrical error bars where Y = data values and 
;	ERR = symmetrical error estimates, enter:
;
;		PLOT, Y			;Plot data
;		ERRPLOT, Y-ERR, Y+ERR	;Overplot error bars.
;
;	If error estimates are non-symetrical, enter:
;
;		PLOT,Y
;		ERRPLOT, Upper, Lower	;Where Upper & Lower are bounds.
;
;	To plot versus a vector of abscissae:
;
;		PLOT, X, Y		  ;Plot data (X versus Y).
;		ERRPLOT, X, Y-ERR, Y+ERR  ;Overplot error estimates.
;
; MODIFICATION HISTORY:
;	DMS, RSI, June, 1983.
;
;	Joe Zawodney, LASP, Univ of Colo., March, 1986. Removed logarithmic
;	restriction.
;
;	DMS, March, 1989.  Modified for Unix IDL.
;       KDB, March, 1997.  Modified to used !p.noclip
;       RJF, Nov, 1997.    Removed unnecessary print statement
;			   Disable and re-enable the symbols for the bars
;	DMS, Dec, 1998.	   Use device coordinates.  Cleaned up logic.
;-
on_error,2                      ;Return to caller if an error occurs
    up = high
    down = low
    xx = x


w = ((n_elements(width) eq 0) ? 0.01 : width) * $ ;Width of error bars
  (!x.window[1] - !x.window[0]) * !d.x_size * 0.5
n = n_elements(up) < n_elements(down) < n_elements(xx) ;# of pnts

for i=0,n-1 do begin            ;do each point.
    xy0 = convert_coord(xx[i], down[i], /DATA, /TO_DEVICE) ;get device coords
    xy1 = convert_coord(xx[i], up[i], /DATA, /TO_DEVICE)

    IF N_ELEMENTS(col) GT 1 THEN CurCol = Col(i) ELSE $
      IF N_ELEMENTS(col) EQ 1 THEN CurCol = Col

    plots, [xy0[0] + [-w, w,0], xy1[0] + [0, -w, w]], $
      [replicate(xy0[1],3), replicate(xy1[1],3)], $
      NOCLIP=!p.noclip, PSYM=0, COLOR=CurCol, /DEVICE
endfor
end
