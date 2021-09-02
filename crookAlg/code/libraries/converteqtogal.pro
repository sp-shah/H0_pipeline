PRO ConvertEqToGal, RA, Dec, b, l
  ; Converts Equatorial Coordinates (alpha, delta) = (RA,Dec)
  ; to Galactic Coordinates (Latitude, Longitude) = (b,l)

  GLACTC, RA, Dec, 2000, l, b, 1

IF 1 EQ 0 THEN BEGIN

  a = DOUBLE(RA)*15*!DTOR
  d = DOUBLE(Dec)*!DTOR

  dNGP = 27.12833 * !DTOR
  aNGP = 12.85 * 15*!DTOR
  lNCP = 123.9 * !DTOR

  sinb = SIN(dNGP)*SIN(d) + COS(dNGP)*COS(d)*COS(a-aNGP)
  sinl2 = COS(d)*SIN(a-aNGP)/SQRT(1-sinb^2)
  cosl2 = (COS(dNGP)*SIN(d) - SIN(dNGP)*COS(d)*COS(a-aNGP))/SQRT(1-sinb^2)

  ; Correct cosl2's that are greater than 1 (by miscalculation)
  gt1 = WHERE(cosl2 GT 1.0)
  lt1 = WHERE(cosl2 LT -1.0)

  IF gt1(0) GE 0 THEN cosl2(gt1) = 1.0
  IF lt1(0) GE 0 THEN cosl2(lt1) = -1.0

  l2 = ACOS(cosl2)

  ; Determine correct quadrant for l2
  sinneg = WHERE(sinl2 LT 0)
  IF sinneg(0) GE 0 THEN l2(sinneg) = 2*!PI - l2(sinneg)

  b = ASIN(sinb) * !RADEG
  l = (lNCP - l2) * !RADEG

  ; Ensure l is between 0 and 360:
  lneg = WHERE(l LT 0)
  
  IF lneg(0) GE 0 THEN l(lneg) = l(lneg)+360.

ENDIF

END
