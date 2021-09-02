; FUNCTION CurveFit_LMS, x, y, A, RtMedSq, FUNCTION_NAME=FuncName
; Least Median Squares Curve-Fitting Procedure
; X, Y are data points
; A is an array containing a first guess of parameters
;   used by the specified function

; Returns:
;  Best value(s) for fit parameters
;  RtMedSq = Root Median Square value of offset 
;    (a measurement of the error on y)


FUNCTION CurveFit_LMS, x, y, A, RtMedSq, FUNCTION_NAME=FuncName

   IF N_ELEMENTS(FuncName) EQ 0 THEN FuncName = 'FUNCT'

   Params = TNMIN('LMSFitFunc', A, BESTMIN=MedianSq, /AUTODERIVATIVE, FUNCTARGS={FUNCTION_NAME:FuncName, XVALUES:x, YVALUES:y})

   RtMedSq = SQRT(MedianSq)

   RETURN, Params

END
