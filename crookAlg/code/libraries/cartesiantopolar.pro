; /GALACTIC - return r, lat, long

PRO CartesianToPolar, x, y, z, r, theta, phi, GALACTIC=galactic

   r = SQRT(DOUBLE(x)^2 + DOUBLE(y)^2 + DOUBLE(z)^2)
   theta = ACOS(DOUBLE(z)/r)

   rho = SQRT(DOUBLE(x)^2+DOUBLE(y)^2)
   phi = ACOS(DOUBLE(x)/rho)

   rhoZero = WHERE(rho EQ 0)
   IF rhoZero(0) GE 0 THEN phi(rhoZero) = 0.

   yNeg = WHERE(y LT 0)
   IF yNeg(0) GE 0 THEN phi(yNeg) = 2*!PI - phi(yNeg)

   rZero = WHERE(r EQ 0.)
   if rZero(0) GE 0 THEN BEGIN
       theta(rZero) = 0.
       phi(rZero) = 0.
   ENDIF

   IF KEYWORD_SET(galactic) THEN BEGIN
       theta = 90 - theta*!RADEG
       phi = phi*!RADEG
   ENDIF

END
