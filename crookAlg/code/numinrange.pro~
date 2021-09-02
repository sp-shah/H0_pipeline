FUNCTION NumInRange, N, MinNum, MaxNum, LOGARITHMIC=logarithmic, EXPONENTIAL=exponential
   ; Generates N Numbers uniformly distributed between MinNum
   ; And MaxNum

   ; If /LOG is set then distribute logarithmically
   ; /If /EXP is set then distribute exponentially

   ; For linear case, set precision & round to avoid e.g. 0.99999998 instead of 1.0

   Precision = 1e-8

   IF KEYWORD_SET(logarithmic) THEN BEGIN
       IF N GT 1 THEN PreFactor = (ALOG10(DOUBLE(MaxNum)) - ALOG10(DOUBLE(MinNum))) / (N-1) ELSE PreFactor = 1.
       LogResult = ALOG10(DOUBLE(MinNum)) + DOUBLE(FINDGEN(N)) * PreFactor
       Result = 10^DOUBLE(LogResult)
   ENDIF ELSE IF KEYWORD_SET(exponential) THEN BEGIN
       IF N GT 1 THEN PreFactor = (EXP(DOUBLE(MaxNum)) - EXP(DOUBLE(MinNum))) / (N-1) ELSE PreFactor = 1.
       ExpResult = EXP(DOUBLE(MinNum)) + DOUBLE(FINDGEN(N)) * PreFactor
       Result = ALOG(DOUBLE(ExpResult))
   ENDIF ELSE BEGIN
       IF N GT 1 THEN PreFactor = DOUBLE(MaxNum - MinNum) / (N-1) ELSE PreFactor = 1
       Result = DOUBLE(MinNum) + DOUBLE(FINDGEN(N)) * PreFactor

; DOESN'T WORK FOR NUMBERS LARGER THAN MAX LONG! Disabled...
;       RoundMul = Result/Precision
;       Result = RoundToMultiple(Result, RoundMul)

   ENDELSE
   
   RETURN, Result  

END
