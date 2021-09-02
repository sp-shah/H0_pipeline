FUNCTION FaintestMag, D, mLim
   ; Returns the faintest absolute magnitude visible at distance D (Mpc)
   ; for a specified apparent magnitude-limit

   RETURN, -5*ALOG10(D) - 25 + mLim

END
