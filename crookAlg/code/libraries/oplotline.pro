PRO OPlotLine, x, y, JUMPLIMIT=JumpLimit, _EXTRA=extra
   ; Over-Plots a line joining the data points [x,y]

;   IF JumpLimit is set, then if the distance between any 2 points is
;   more than that value they will be split into 2 separate lines

   IF N_ELEMENTS(JumpLimit) EQ 0 THEN BEGIN
       OPLOT, x, y, _EXTRA=extra
   ENDIF ELSE  BEGIN
       ind = FINDGEN(N_ELEMENTS(x)-1)
       Gap = SQRT( (x(ind+1)-x(ind))^2 + (y(ind+1)-y(ind))^2 )
       
       BreakLine = WHERE(Gap GT JumpLimit)

       NextPlot = 0
       FOR i = 0, WhereSize(BreakLine)-1 DO BEGIN
           OPLOT, x(NextPlot:BreakLine(i)),y(NextPlot:BreakLine(i)), $
             _EXTRA=extra
           NextPlot = BreakLine(i) + 1
       ENDFOR

       OPLOT, x(NextPlot:N_ELEMENTS(x)-1),y(NextPlot:N_ELEMENTS(x)-1), $
         _EXTRA=extra
       
   ENDELSE

END
