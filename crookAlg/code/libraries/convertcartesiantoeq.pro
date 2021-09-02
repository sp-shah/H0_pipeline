; Converts RA, Dec to x, y, z values of points on a unit sphere

PRO ConvertCartesianToEq, x, y, z, RA, Dec
   xyrad = SQRT(x^2+y^2)
   RA = ACOS(x/xyrad) * 12 / !PI
   yNeg = WHERE(y LT 0)
   IF yNeg(0) GE 0 THEN RA(yNeg) = 24 - RA(yNeg)

   Dec = ATAN(z/xyrad) * !RADEG

END
