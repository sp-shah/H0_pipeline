FUNCTION Integral, x, y, FAST=fast
   ; Uses INT_TABULATE to compute integral of x.dy for all x values
   ; This procedure is not efficient, since the calculation is repeated

   Result = DBLARR(N_ELEMENTS(x))

   IF KEYWORD_SET(fast) THEN BEGIN

       FOR i = 1, N_ELEMENTS(x)-1 DO BEGIN
           Result(i) = Result(i-1) + 0.5*(x(i)-x(i-1))*(y(i)+y(i-1))
       ENDFOR

   ENDIF ELSE BEGIN

       FOR i = 1, N_ELEMENTS(x)-1 DO BEGIN
           Result(i) = INT_TABULATED(x(0:i), y(0:i))
       ENDFOR
       
   ENDELSE

   RETURN, Result

END
