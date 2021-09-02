; Linear fit forced through origin, using Least Median Squares Technique
; Y = aX

; If /IMPROVETRIAL is set, then try 100 gradients between 0 and 1
; to get best starting value of the gradient

FUNCTION LinFit_BestTrial, N, x, y

   TrialAngle = (!PI/2) * (1+FINDGEN(N)) / (N+1)
   TrialGrad = TAN(TrialAngle)

   Result = FLTARR(N)

   FOR i = 0, N-1 DO BEGIN
       Result(i) = LMSFitFunc([TrialGrad(i)], XVALUES=x, YVALUES=y, FUNCTION_NAME='StraightLine_Origin')
   ENDFOR

   BestTrial = MIN(Result, indMin)

   RETURN, TrialGrad(indMin)

END


FUNCTION LinFit_Origin_LMS, x, y, RMS=RtMedSq, IMPROVETRIAL=ImproveTrial
  
   IF KEYWORD_SET(ImproveTrial) THEN BEGIN
       ; Find the best Trial A by sampling
       ; This currently only works for +ve correlations!!
       TrialA = LinFit_BestTrial(100,x,y)
   ENDIF ELSE BEGIN
       ; Quick method for Trial A
       x1 = Percentile(x, [20,80])
       y1 = Percentile(y, [20,80])
       TrialA = (y1(1)-y1(0)) / (x1(1)-x1(0))
   ENDELSE
  
   A = [TrialA]
   
   Result = CURVEFIT_LMS(X, Y, A, RtMedSq, FUNCTION_NAME='StraightLine_Origin')

   RETURN, Result(0)

END
