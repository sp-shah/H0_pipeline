FUNCTION ArrayAND, x
   ; Return x(0)AND x(1) AND x(2) AND ...

   Result = x(0)
   FOR i = 1, N_ELEMENTS(x)-1 DO Result = Result AND x(i)
       
   RETURN, Result

END
