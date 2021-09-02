FUNCTION Separation, x1, y1, z1, x2, y2, z2
   ; Given 2 3-vector positions, compute the value of |r1-r2|

   RETURN, SQRT((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2)

END
