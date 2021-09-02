FUNCTION ATANQuad, y, x
   ; Computes ATAN(y/x) and returns answer in correct quadrant

   Result = ACOS(x / SQRT(x^2+y^2) )
   SignFlip = WHERE(y LT 0)
   IF SignFlip(0) GE 0 THEN Result(SignFlip) = 2*!PI - Result(SignFlip) 
   
   RETURN, Result

END
