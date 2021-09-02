PRO MollweideInverse, x, y, phi, lambda, LAMBDA0=lambda0
   ; Inverts the Mollweide Projection from x, y to phi (lat), lambda (long)

   IF N_ELEMENTS(lambda0) EQ 0 THEN lambda0 = 0.

   theta = ASIN(y/SQRT(2))

   phi = !RADEG*ASIN((2*theta + SIN(2*theta)) / !PI)
   lambda1 = !RADEG * !PI*x/(-2*SQRT(2)*COS(theta))

   lambda = NumInInterval(lambda1 + lambda0,0,360)

   NotValid = WHERE(ABS(lambda1) GT 180)

   IF NotValid(0) GE 0 THEN BEGIN
       ; Certain Coords are not valid projections
       lambda(NotValid) = !VALUES.F_NAN
   ENDIF
END
