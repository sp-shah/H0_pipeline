; Linear fit forced through origin
; Y = aX

FUNCTION LinFit_Origin, x, y, WEIGHTS=Weights, SIGMA=Sigma

   IF N_ELEMENTS(Weights) EQ 0 THEN Weights = REPLICATE(1.0, N_ELEMENTS(x))
   
   x1 = Percentile(x, [20,80])
   y1 = Percentile(y, [20,80])
   TrialA = (y1(1)-y1(0)) / (x1(1)-x1(0))
   A = [TrialA]

   yfit = CURVEFIT(X, Y, weights, A, Sigma, FUNCTION_NAME='StraightLine_Origin')


   RETURN, A(0)

END
