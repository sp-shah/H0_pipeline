FUNCTION Sign, x
   ; Returns 1 if +ve, -1 if -ve for each element in array

   retX = x
   indZero = WHERE(x EQ 0., COMPLEMENT=indNonZero)

   IF indZero(0) GE 0 THEN retX(indZero) = 1
   IF indNonZero(0) GE 0 THEN retX(indNonZero) = x / ABS(x)

   RETURN, retX

END
