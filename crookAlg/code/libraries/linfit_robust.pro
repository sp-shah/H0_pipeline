; Robust Fitting Function for a straight line

PRO CurveFitFunc_Line, X, A, F, pder
   ; Function can be called by CURVEFIT to fit a straight line to the data
   F = A(0) + A(1)*X
   
   IF N_PARAMS() GT 3 THEN BEGIN
       pder = [[REPLICATE(1., N_ELEMENTS(X))], [X]]
   ENDIF

END


FUNCTION LINFIT_Robust, X, Y, WEIGHTS=weights, SIGMA=sigma
   IF N_ELEMENTS(weights) EQ 0 THEN weights = REPLICATE(1.0, N_ELEMENTS(X))

   A = LINFIT(X,Y)
   
   y1 = CURVEFIT_Robust(X, Y, weights, A, sigma, FUNCTION_NAME='CurveFitFunc_Line')
     
   RETURN, A

END
