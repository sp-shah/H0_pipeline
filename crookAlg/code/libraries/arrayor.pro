FUNCTION ArrayOR, x
   ; Return x(0) OR x(1) OR x(2) OR ...

   Result = x(0)
   FOR i = 1, N_ELEMENTS(x)-1 DO Result = Result OR x(i)
       
   RETURN, Result

END
