FUNCTION Interpol_Low, V, X, U
                                ; Same as INTERPOL, but returns first
                                ; encounter, rather than largest one

   i = 0
   Xmax = REPLICATE(N_ELEMENTS(X)-1, N_ELEMENTS(U))
   count = 0
   Result = U
   
   WHILE i LT N_ELEMENTS(X) AND (count LT N_ELEMENTS(U)) DO BEGIN
       indFound = WHERE(U LT X(i) AND Xmax EQ 0)
       IF indFound(0) GE 0 THEN BEGIN
           Xmax(indFound) = i       
           count = count + N_ELEMENTS(indFound)
       ENDIF
       i++
   ENDWHILE

   FOR j = 0, N_ELEMENTS(U)-1 DO BEGIN
       Result(j) = INTERPOL(V(0:Xmax(j)), X(0:Xmax(j)), U(j))
   ENDFOR

   RETURN, Result

END
