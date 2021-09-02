
FUNCTION PolarAngSep, Theta1, Phi1, Theta2, Phi2
   ; Calculates the angular separation between (Theta1, Phi1)
   ; and (Theta2, Phi2)
   ; One or Both may be lists.

   ; In Cartesian Coordinates:
   z1 = COS(DOUBLE(Theta1))
   r1 = SIN(DOUBLE(Theta1))
   x1 = r1*COS(DOUBLE(Phi1))
   y1 = r1*SIN(DOUBLE(Phi1))

   z2 = COS(DOUBLE(Theta2))
   r2 = SIN(DOUBLE(Theta2))
   x2 = r2*COS(DOUBLE(Phi2))
   y2 = r2*SIN(DOUBLE(Phi2))
 
   ; Compute Dot Products 
   DotProduct = x1*x2 + y1*y2 + z1*z2  ; (This is Cos of angle)

   RETURN, ACOS(DotProduct)

END
