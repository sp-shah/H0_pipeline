FUNCTION GenerateErr, Sigma, N=N, POSITIVE=positive, MEAN=MeanVal
; If POSITIVE set then ensure error is positive, requires MEANVAL so
; know what positive is.

   IF KEYWORD_SET(positive) THEN BEGIN
       IF N_ELEMENTS(Sigma) EQ 1 AND N_ELEMENTS(N) GT 0 THEN BEGIN
           sigma1 = REPLICATE(sigma, N)
           MeanVal1 = REPLICATE(MeanVal, N)
           Result = GenerateErr_Positive(MeanVal1, Sigma1)
       ENDIF ELSE Result = GenerateErr_Positive(MeanVal, Sigma)
   ENDIF ELSE BEGIN

       IF N_ELEMENTS(N) EQ 0 THEN N = N_ELEMENTS(Sigma)
       
       RandomNum = RANDOMN(seed, N)
       Result = RandomNum*Sigma
   ENDELSE
 
   RETURN, Result

END
