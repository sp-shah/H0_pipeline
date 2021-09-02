PRO CumPlot, y, x _EXTRA=extra

; Cumulative Plot
; y are the data values
; x (optional) are the count values
  
   IF N_ELEMENTS(x) EQ 0 THEN BEGIN
       x = FINDGEN(N_ELEMENTS(y))+1
       indOrder = SORT(y)
       xSorted = x
   ENDIF ELSE BEGIN
       indOrder = SORT(x)
       xSorted = x(indOrder)
   ENDELSE

   yCum = y(indOrder)
   FOR i = 1, N_ELEMENTS(yCum)-1 DO yCum(i) = yCum(i) + yCum(i-1)
   
   yTot = yCum(N_ELEMENTS(yCum)-1)
   
   EnhancedPLOT, xSorted, yCum / yTot, _EXTRA=extra
   STOP
END
