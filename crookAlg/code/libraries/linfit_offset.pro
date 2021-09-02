; NOT TESTED!!!
; Linear fit with offset, but forced gradient of unity
; Y = X + C

PRO StraightLine_GradUnity, X, Param, F, pder
   ; Straight Line that passes through origin with gradient Param(0)
   ; Can be used in curve-fitting procedures
   F = Param(0) + X

   ; If the procedure is called with four parameters, calculate the partial derivative:
   IF N_PARAMS() GE 4 THEN pder = [[REPLICATE(1.0, N_ELEMENTS(X))]]

END


FUNCTION LinFit_Offset, x, y, WEIGHT=Weights, SIGMA=Sigma

   IF N_ELEMENTS(Weights) EQ 0 THEN Weights = REPLICATE(1.0, N_ELEMENTS(x))
   
   TrialC = MEDIAN(x) - MEDIAN(y)
   C = [TrialC]

   yfit = CURVEFIT(X, Y, weights, C, Sigma, FUNCTION_NAME='StraightLine_GradUnity')


   RETURN, C(0)

END
