PRO PolarToCartesian, r, theta, phi, x, y, z, GALACTIC=galactic

   ; If /GALACTIC, then angle measured up from x-y plane
   ; and units are degrees

   IF KEYWORD_SET(galactic) THEN BEGIN
       theta1 = (90-theta)*!DTOR
       phi1   = phi*!DTOR
   ENDIF ELSE BEGIN
       theta1 = theta
       phi1   = phi
   ENDELSE

   z = r*COS(theta1)
   xy =r*SIN(theta1)
   x = xy*COS(phi1)
   y = xy*SIN(phi1)

END
