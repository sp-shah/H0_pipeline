; Runs the PLOT routine, but allows COL to be an array

PRO PlotCol, x, y, COLOR=col, PSYM=psym, _EXTRA=extra
   IF N_ELEMENTS(col) LE 1 THEN BEGIN
       PLOT, x, y, COLOR=col, _EXTRA=extra
   ENDIF ELSE BEGIN
        PLOT, x, y, /NODATA, _EXTRA=extra
        ColorOverlay, x, y, col, PSYM=psym
   ENDELSE
END
