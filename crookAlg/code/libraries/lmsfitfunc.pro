; Returns the Least Media Squares Value for x & y values fitted to a
; specified function


FUNCTION LMSFitFunc, Param, XVALUES=xVal, YVALUES=yVal, FUNCTION_NAME=funcname
   
   CALL_PROCEDURE, funcname, xVal, Param, F

   OffsetSq = (yVal - F)^2

   ; For Least Squares Fit, return TOTAL(OffsetSq)
   ; For Least Median Squares Fit return MEDIAN(OffsetSq)
   
   RetVal = MEDIAN(OffsetSq)

   RETURN, RetVal
END
