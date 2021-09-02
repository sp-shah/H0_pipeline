FUNCTION HelioToCMB, vIn, b, l, REVERSE=reverse
   ; Converts Heliocentric velicities to CMB-centric ones
   ; /REVERSE will convert vCMB to vHel

   CMBDipole_Sun, lSunCMB, bSunCMB, vSunCMB, /RADIANS

   vMod = vSunCMB * ( SIN(DOUBLE(b)*!DTOR)*SIN(bSunCMB) + COS(DOUBLE(b)*!DTOR)*COS(bSunCMB)*COS(DOUBLE(l)*!DTOR - lSunCMB) )

   IF NOT KEYWORD_SET(reverse) THEN RETURN, vIn + vMod $
     ELSE RETURN, vIn - vMod
      
END
