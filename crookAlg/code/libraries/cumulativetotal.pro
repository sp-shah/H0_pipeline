FUNCTION CumulativeTotal, x
   ; Returns y(i) = sum(x(0:i))

   y = x
   FOR i = 1L, N_ELEMENTS(x)-1 DO BEGIN
       y(i) = y(i) + y(i-1)
   ENDFOR

   RETURN, y

END
