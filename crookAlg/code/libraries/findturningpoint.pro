FUNCTION FindTurningPoint, x, y, MIN=TPMin, MAX=TPMax
   ; Find the turning point (assuming only 1) in y(x)
   ; If y is matrix, return a vector of TPs
   ; The returned value is the index of the turning point (-1 if none or 2+)
   ; TPMin/Max is a vector of Minimums/Maximums

   N = N_ELEMENTS(y(*,0))
   Np = N_ELEMENTS(y(0,*))
   IF Np GT 1 THEN Result = INTARR(Np) ELSE Result = 0
   Result(*) = -1
   TPMin = Result
   TPMax = Result
   

   FOR i = 0, Np-1 DO BEGIN
       NoMin = 0
       NoMax = 0

       yMin = MIN(y(*,i), indMin)
       yMax = MAX(y(*,i), indMax)
       TPMin(i) = indMin
       TPMax(i) = indMax

       IF (indMin EQ 0) OR (indMin EQ N-1) THEN NoMin = 1
       IF (indMax EQ 0) OR (indMax EQ N-1) THEN NoMax = 1

       IF (NoMax EQ 0) AND (NoMin EQ 1) THEN $
         Result(i) = indMax ELSE $
         IF (NoMax EQ 1) AND (NoMin EQ 0) THEN Result(i) = indMin

   ENDFOR

   RETURN, Result

END
