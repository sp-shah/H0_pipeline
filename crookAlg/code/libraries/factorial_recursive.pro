FUNCTION Factorial_Recursive, N
   IF N LE 1 THEN RETURN, DOUBLE(N) ELSE $
     RETURN, DOUBLE(N)*Factorial_Recursive(N-1)
END
