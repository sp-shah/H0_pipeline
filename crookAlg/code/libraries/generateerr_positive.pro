FUNCTION GenerateErr_Positive, x, Sigma
; For simulating errors, return Rand*Sigma, but draw from clipped
; gaussian (symmetric) so that resulting number is always positive


   N = N_ELEMENTS(x)
   Compute = REPLICATE(1,N)
   Cont = 1
   indCalc = WHERE(Compute EQ 1)
   
   Result = FLTARR(N_ELEMENTS(x))

   WHILE indCalc(0) GE 0 DO BEGIN
      
       RandomNum = RANDOMN(seed, N_ELEMENTS(indCalc))
       Result(indCalc) = RandomNum*Sigma(indCalc)
       
       indOK = WHERE(ABS(Result(indCalc)) LT ABS(x(indCalc)))
       
       IF indOK(0) GE 0 THEN Compute(indCalc(indOK)) = 0

       indCalc = WHERE(Compute EQ 1)
       
   ENDWHILE

   RETURN, Result

END
