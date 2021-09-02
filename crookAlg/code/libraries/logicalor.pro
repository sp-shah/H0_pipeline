; Performs Logical "OR" on all elements of array x

FUNCTION LogicalOR, x
   Result = x(0)
   FOR i = 1, N_ELEMENTS(x)-1 DO BEGIN
       Result = Result OR x(i)
   ENDFOR
   RETURN, Result
END
