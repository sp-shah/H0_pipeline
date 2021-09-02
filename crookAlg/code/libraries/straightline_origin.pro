PRO StraightLine_Origin, X, Param, F, pder
   ; Straight Line that passes through origin with gradient Param(0)
   ; Can be used in curve-fitting procedures
   F = Param(0)*X

   ; If the procedure is called with four parameters, calculate the partial derivative:
   IF N_PARAMS() GE 4 THEN pder = [[X]] 

END
