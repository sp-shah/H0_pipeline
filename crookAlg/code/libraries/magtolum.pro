FUNCTION MagToLum, M, Msun
   ; Converts Absolute Magnitude to Luminosity in Solar units

   IF NOT KEYWORD_SET(Msun) THEN Msun = !MBolSun

   L = 10^DOUBLE(0.4*(Msun - M))
   RETURN, L

END
