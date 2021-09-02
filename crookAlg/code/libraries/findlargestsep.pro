; Finds the largest separation between all points in the data set
; given the x and y coordinates of the points.
; Returns the separation and the indices of the points

FUNCTION FindLargestSep, x, y, ind1, ind2
   N = N_ELEMENTS(x)
   
   MaxSepStore = 0.

   FOR i = 0, N - 2 DO BEGIN
      CompareInd = FIX(FINDGEN(N-i-1)) + (i+1)
      SeparationSq = (x(CompareInd) - x(i))^2 + (y(CompareInd) - y(i))^2
      MaxSep = MAX(SeparationSq, ind)

      IF MaxSep GT MaxSepStore THEN BEGIN
          MaxSepStore = MaxSep
          ind1 = i
          ind2 = CompareInd(ind)
      ENDIF
  ENDFOR
  
  RETURN, SQRT(MaxSepStore)

END
