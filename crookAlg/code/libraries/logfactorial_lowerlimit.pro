; Compute the ALOG( N(N-1)(N-2)...(Nmin+1)Nmin )

FUNCTION LogFactorial_LowerLimit, N, Nmin
   IF N LT NMin THEN RETURN, 0 ELSE $
     IF N EQ Nmin THEN RETURN, ALOG(DOUBLE(N)) ELSE $
     RETURN, ALOG(DOUBLE(N))+LogFactorial_LowerLimit(N-1, Nmin)
END
