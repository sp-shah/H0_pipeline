FUNCTION Factorial_LowerLimit, N, Nmin
   ; Recursive function that returns N(N-1)(N-2)...(Nmin+1)Nmin

   IF N LT NMin THEN RETURN, 1 ELSE $
     IF N EQ Nmin THEN RETURN, Nmin ELSE $
     RETURN, DOUBLE(N)*Factorial_LowerLimit(N-1, Nmin)

END
