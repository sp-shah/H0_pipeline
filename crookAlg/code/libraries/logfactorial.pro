; Compute the ALOG( N(N-1)(N-2)...1 )

FUNCTION LogFactorial, N
   RETURN, LogFactorial_LowerLimit(N, 1)
END
