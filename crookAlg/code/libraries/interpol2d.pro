FUNCTION Interpol2D, Value, x, y, xNewGrid, yNewGrid, GRID=grid
   ; Given a set of values at grid points (Value)
   ; And the locations of the grid points x, y
   ; Compute interpolated values at xNewGrid, yNewGrid
   ; Values must be a 2D array Value(xInd, yInd) = Val

   ; If /GRID is set then compuet values at all combinations of 
   ; x and y and return a 2x2 array



   IF KEYWORD_SET(grid) THEN BEGIN
       
       xNew = FLTARR(N_ELEMENTS(xNewGrid) * N_ELEMENTS(yNewGrid))
       yNew = FLTARR(N_ELEMENTS(xNewGrid) * N_ELEMENTS(yNewGrid))
       
       FOR i = 0, N_ELEMENTS(xNewGrid) - 1 DO BEGIN
           yNew(i*N_ELEMENTS(yNewGrid):N_ELEMENTS(yNewGrid)*(i+1)-1) = yNewGrid
           xNew(i*N_ELEMENTS(ynewGrid):N_ELEMENTS(yNewGrid)*(i+1)-1) = REPLICATE(xNewGrid(i), N_ELEMENTS(yNewGrid))
       ENDFOR
   ENDIF ELSE BEGIN
       xNew = xNewGrid
       yNew = yNewGrid
   ENDELSE

   ; Find Values of nearest grid points that are equal
   ; to or greater than vales of xNew, yNew

   newXind = SORT(xNew)
   newYind = SORT(yNew)

   xPointsSorted = FindLargerValues( x, xNew(newXind) )
   xAbove = xPointsSorted(newXind)

   yPointsSorted = FindLargerValues( y, yNew(newYind) )
   yAbove = yPointsSorted(newYind)

   xBelow = xAbove - 1
   yBelow = yAbove - 1

   xNegInd = WHERE(xBelow LT 0 AND x(xAbove) EQ xNew)
   IF xNegInd(0) GE 0 THEN BEGIN
       xBelow(xNegInd) = 0
       xAbove(xNegInd) = 1       
   ENDIF

   yNegInd = WHERE(yBelow LT 0 AND y(yAbove) EQ yNew)
   IF yNegInd(0) GE 0 THEN BEGIN
       yBelow(yNegInd) = 0
       yAbove(yNegInd) = 1       
   ENDIF


   ; Compute x value that want to interpolate Y at:
   
   ValAbove = Value(xBelow,yAbove) + $
     (Value(xAbove,yAbove) - Value(xBelow,yAbove)) * $
     (xNew-x(xBelow)) / (x(xAbove) - x(xBelow))

   ValBelow = Value(xBelow,yBelow) + $
     (Value(xAbove,yBelow) - Value(xBelow,yBelow)) * $
     (xNew-x(xBelow)) / (x(xAbove) - x(xBelow))

   ; Now compute result

   NewValue = ValBelow + (ValAbove - ValBelow) * (yNew - y(yBelow) ) / (y(yAbove) - y(yBelow))

   IF KEYWORD_SET(grid) THEN BEGIN
       FinalValue = FLTARR(N_ELEMENTS(xNewGrid), N_ELEMENTS(yNewGrid))

       FOR i = 0, N_ELEMENTS(xNewGrid) - 1 DO BEGIN
           FinalValue(i,*) = NewValue(i*N_ELEMENTS(yNewGrid):N_ELEMENTS(yNewGrid)*(i+1)-1)
       ENDFOR
   ENDIF ELSE FinalValue = NewValue

   RETURN, FinalValue

END

