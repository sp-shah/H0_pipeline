; Computes the minimum luminosity visible at a distance D (Mpc) for a
; specified apparent magnitude limit

FUNCTION MinLuminosity, D, MagLim, Msun

   AbsMag = MagLim - (25 + 5*ALOG10(D)) ; Minimum absolute magnitude
   RETURN, MagToLum(AbsMag, Msun)

END
