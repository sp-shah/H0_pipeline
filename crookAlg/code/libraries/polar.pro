; Converts 2-D Cartesian Coordinates into Polars

PRO Polar, x, y, r, theta
   r = SQRT(x^2 + y^2)

   theta = ACOS(x/r)
   indNeg = WHERE(y LT 0)
   IF indNeg(0) GE 0 THEN theta(indNeg) = 2*!PI - theta(indNeg)

END
