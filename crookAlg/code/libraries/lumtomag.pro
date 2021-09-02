FUNCTION LumToMag, L, Msun
   ; Converts Luminosity in Solar units to an Absolute Magnitude

   IF NOT KEYWORD_SET(Msun) THEN Msun = 4.75

   M = Msun - 2.5*ALOG10(L)
   RETURN, M

END
