; like ARROW, but allows color to be an array

; /BALLBASE plots an open circle at the base of the arrow

PRO EnhancedArrow, x0, y0, x1, y1, BALLBASE=ballbase, COLOR=col, _EXTRA=extra
   PlotSym2, 0

   IF N_ELEMENTS(col) GT 1 THEN BEGIN
       FOR i = 0L, N_ELEMENTS(col)-1 DO BEGIN
           ARROW, x0(i), y0(i), x1(i), y1(i), COLOR=col(i), _EXTRA=extra
           IF N_ELEMENTS(ballbase) GT 0 THEN OPLOT, [x0(i)],[y0(i)], PSYM=8, COL=col(i), SYMSIZE=ballbase
       ENDFOR
   ENDIF ELSE BEGIN
       ARROW, x0, y0, x1, y1, COLOR=col, _EXTRA=extra
       IF N_ELEMENTS(ballbase) GT 0 THEN OPLOT, [x0(i)],[y0(i)], PSYM=8, COL=col, SYMSIZE=ballbase
   ENDELSE
END
