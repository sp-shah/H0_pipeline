PRO ConvertGalToEq, gal_b, gal_l, RA, Dec
  ; Converts Galactic Coordinates (Latitude, Longitude) = (gal_b,gal_l) 
  ; to Equatorial Coordinates (alpha, delta) = (RA,Dec)


  GLACTC, RA, Dec, 2000, gal_l, gal_b, 2

IF 1 EQ 0 THEN BEGIN

  b = DOUBLE(gal_b)*!DTOR
  l = DOUBLE(gal_l)*!DTOR

  l0 = 33.0 * !DTOR
  s0 = 62.6 * !DTOR
  a0 = 282.25 * !DTOR

  sind = COS(b)*SIN(l-l0)*SIN(s0) + SIN(b)*COS(s0)

  cosa2 = COS(b)*COS(l-l0) / SQRT(1-(sind)^2)
  sina2 = (COS(b)*SIN(l-l0)*COS(s0) - SIN(b)*SIN(s0)) / SQRT(1-(sind)^2)

  ; Correct cosa2's that are greater than 1 (by miscalculation)
  gt1 = WHERE(cosa2 GT 1.0)
  lt1 = WHERE(cosa2 LT -1.0)

  IF gt1(0) GE 0 THEN cosa2(gt1) = 1.0
  IF lt1(0) GE 0 THEN cosa2(lt1) = -1.0

  a2 = ACOS(cosa2)

  ; Determine correct quadrant for a2
  sinneg = WHERE(sina2 LT 0)
  IF sinneg(0) GE 0 THEN a2(sinneg) = 2*!PI - a2(sinneg)

  Dec = ASIN(sind) * !RADEG
  RA = (a2 + a0)*!RADEG / 15

  ; Ensure RA is between 0 and 24.
  toobig = WHERE(RA GE 24)
  
  IF toobig(0) GE 0 THEN RA(toobig) = RA(toobig) - 24.

ENDIF

END
