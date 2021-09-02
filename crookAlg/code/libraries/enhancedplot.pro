; /LINEERROR will connect dots of error limits rather than drawing
; error bars

; /ELLIPSEERROR will draw ellipses for the error bars if both x and y
; errors present

; If a filename is provided for quick save, then a basic copy will be saved
; to an EPS file of that name (does not work with /OPLOT)

; LABELS will plot text on the graph at the provided points
;  (must be an array same size as x)

PRO EnhancedPlot, x, y, XLOW=xLow, XHIGH=xHigh, YLOW=yLow, YHIGH=yHigh, $
                  XERR=xErr, YERR=yErr, OPLOT=oplot, $
                  COLOR=col, ERRCOL=errcol, ERRWIDTH=errwidth, $
                  LINEERROR=lineerror, ELLIPSEERROR=ellipseerror, $
                  LABELS=labels, CHARSIZE=charsize, CHARTHICK=charthick, $
                  QUICKSAVE=FileName, $
                  ASPECTRATIO=aspectratio, $
                  PSYM=psym, SYMSIZE=symsize, XRANGE=xrange, YRANGE=yrange, $
                  LINESTYLE=linestyle, THICK=thick, $
                  _EXTRA=extra

   ; Creates a Plot an overplots error bars

   IF N_ELEMENTS(xErr) GT 0 THEN BEGIN
       xLow = x - xErr
       xHigh = x + xErr
   ENDIF

   IF N_ELEMENTS(yErr) GT 0 THEN BEGIN
       yLow = y - yErr
       yHigh = y + yErr
   ENDIF

   IF NOT KEYWORD_SET(oplot) THEN BEGIN
       
       IF N_ELEMENTS(xrange) EQ 0 THEN BEGIN
           IF N_ELEMENTS(xLow) GT 0 THEN xMin = MIN(xLow) ELSE $
             xMin = MIN(x)
           IF N_ELEMENTS(xHigh) GT 0 THEN xMax = MAX(xHigh) ELSE $
             xMax = MAX(x)
           xrange=[xMin, xMax]
       ENDIF
       
       IF N_ELEMENTS(yrange) EQ 0 THEN Begin
           IF N_ELEMENTS(yLow) GT 0 THEN yMin = MIN(yLow) ELSE $
             yMin = MIN(y)
           IF N_ELEMENTS(yHigh) GT 0 THEN yMax = MAX(yHigh) ELSE $
             yMax = MAX(y)
           yrange=[yMin, yMax]
       ENDIF
       
   ENDIF

   
   IF KEYWORD_SET(FileName) AND NOT KEYWORD_SET(oplot) THEN repCount = 1 ELSE repCount = 0

   FOR k = 0, repCount DO BEGIN
       IF k GT 0 THEN OpenEPS, FileName, ASPECTRATIO=aspectratio

       IF N_ELEMENTS(col) LE 1 THEN BEGIN
           IF KEYWORD_SET(oplot) THEN BEGIN
               OPLOT, x, y, COLOR=col, PSYM=psym, SYMSIZE=symsize, $
                 LINESTYLE=linestyle, THICK=thick, _EXTRA=extra
           ENDIF ELSE BEGIN
               PLOT, x, y, COLOR=col, PSYM=psym, SYMSIZE=symsize, $
                 LINESTYLE=linestyle, THICK=thick, _EXTRA=extra, $
                 XRANGE=xrange, YRANGE=yrange
           ENDELSE
       ENDIF ELSE BEGIN
           IF NOT KEYWORD_SET(oplot) THEN BEGIN
               PLOT, x, y, /NODATA, _EXTRA=extra, $
                 XRANGE=xrange, YRANGE=yrange
           ENDIF
           IF N_ELEMENTS(psym) GT 0 THEN BEGIN
               FOR i = 0L, N_ELEMENTS(col)-1 DO BEGIN
                   OPLOT, [x(i)], [y(i)], COLOR=col(i), PSYM=psym, SYMSIZE=symsize
               ENDFOR
           ENDIF ELSE BEGIN
               FOR i = 1L, N_ELEMENTS(col)-1 DO BEGIN
                   OPLOT, [x(i-1),x(i)], [y(i-1),y(i)], COLOR=col(i), LINESTYLE=linestyle, THICK=thick
               ENDFOR
           ENDELSE
       ENDELSE       
       
       IF NOT KEYWORD_SET(errcol) AND N_ELEMENTS(col) GT 0 THEN errcol=col
       
       IF KEYWORD_SET(ellipseerror) THEN BEGIN
           IF N_ELEMENTS(xLow) GT 0 AND N_ELEMENTS(yLow) GT 0 THEN BEGIN
               ; Draw quarter ellipses at a time
               FOR i = 0, N_ELEMENTS(xLow)-1 DO BEGIN
                   EllipseXY, (xHigh(i) - x(i)), (yHigh(i)-y(i)), 0, xPlot1, yPlot1, ANGLERANGE=[0,90], XCENTER=x(i), YCENTER=y(i)
                   EllipseXY, (x(i)-xLow(i)), (yHigh(i)-y(i)), 0, xPlot2, yPlot2, ANGLERANGE=[90,180], XCENTER=x(i), YCENTER=y(i)
                   EllipseXY, (x(i) - xLow(i)), (y(i)-yLow(i)), 0, xPlot3, yPlot3, ANGLERANGE=[180,270], XCENTER=x(i), YCENTER=y(i)
                   EllipseXY, (xHigh(i) - x(i)), (y(i)-yLow(i)), 0, xPlot4, yPlot4, ANGLERANGE=[270,360], XCENTER=x(i), YCENTER=y(i)

                   OPLOT, [xPlot1, xPlot2, xPlot3, xPlot4], [yPlot1, yPlot2, yPlot3, yPlot4], COL=errcol

               ENDFOR
               
           ENDIF
       ENDIF ELSE IF NOT KEYWORD_SET(lineerror) THEN BEGIN
           
           IF N_ELEMENTS(xLow) GT 0 THEN $
             ErrPlotX, y, xLow, xHigh, COL=errcol, WIDTH=errwidth  
           
           IF N_ELEMENTS(yLow) GT 0 THEN $
             ErrPlotY, x, yLow, yHigh, COL=errcol, WIDTH=errwidth
           
       ENDIF ELSE BEGIN
           
           IF N_ELEMENTS(xLow) GT 0 THEN BEGIN
               EnhancedPLOT, xLow, y, COL=errcol, LINESTYLE=1, /OPLOT
               EnhancedPLOT, xHigh, y, COL=errcol, LINESTYLE=1, /OPLOT
           ENDIF
           
           IF N_ELEMENTS(yLow) GT 0 THEN BEGIN
               EnhancedPLOT, x, yLow, COL=errcol, LINESTYLE=1, /OPLOT
               EnhancedPLOT, x, yHigh, COL=errcol, LINESTYLE=1, /OPLOT
           ENDIF
           
       ENDELSE
       
       IF N_ELEMENTS(labels) GT 0 THEN BEGIN
           IF N_ELEMENTS(col) GT 1 THEN BEGIN
               FOR i = 0, N_ELEMENTS(labels)-1 DO BEGIN
                   XYOUTS, x(i), y(i), labels(i), CHARSIZE=charsize, CHARTHICK=charthick, COLOR=col(i)
               ENDFOR           
           ENDIF ELSE BEGIN
               XYOUTS, x, y, labels, CHARSIZE=charsize, CHARTHICK=charthick, COLOR=col
           ENDELSE
       ENDIF
       
       IF k GT 0 THEN CloseEPS

   ENDFOR

END
