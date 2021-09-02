FUNCTION LGToCMB, vIn, b, l, REVERSE=reverse
   ; Converts LG-centric velicities to CMB-centric ones
   ; /REVERSE will convert vCMB to vLG

   ; Helio to LG
   vSunLG =        306.  ; +/- 18 km/s
   lSunLG = !DTOR*  99.  ; +/- 5 deg
   bSunLG = !DTOR* (-4.) ; +/- 4 deg

   CMBDipole_Sun, lSunCMB, bSunCMB, vSunCMB, /RADIANS

   xMod = -vSunLG*COS(bSunLG)*COS(lSunLG) + vSunCMB*COS(bSunCMB)*COS(lSunCMB)
   yMod = -vSunLG*COS(bSunLG)*SIN(lSunLG) + vSunCMB*COS(bSunCMB)*SIN(lSunCMB) 
   zMod = -vSunLG*SIN(bSunLG)             + vSunCMB*SIN(bSunCMB)

   ; 621.6 km/s towards 28.51, 272.31

   vMod = xMod*COS(DOUBLE(l)*!DTOR)*COS(DOUBLE(b)*!DTOR) + yMod*SIN(DOUBLE(l)*!DTOR)*COS(DOUBLE(b)*!DTOR) +zMod*SIN(DOUBLE(b)*!DTOR)

   IF NOT KEYWORD_SET(reverse) THEN RETURN, vIn + vMod $
   ELSE RETURN, vIn - vMod


   ; Erdogdu et al. params:
;   bLG = 29.
;   lLG = 273.
;   vLG = 627.

;   vMod = vLG * ( SIN(DOUBLE(b)*!DTOR)*SIN(bLG) + COS(DOUBLE(b)*!DTOR)*COS(bLG)*COS(ABS(DOUBLE(l)*!DTOR - lLG)) )

;   IF NOT KEYWORD_SET(reverse) THEN RETURN, vIn + vMod $
;     ELSE RETURN, vIn - vMod
      
END
