FUNCTION HelioToLG, vIn, b, l, REVERSE=reverse, OLD=old
   ; Converts Heliocentric velicities to LG-centric ones
   ; /REVERSE will convert vLG to vHel
   ; /OLD uses old Courteau values (not revised ones)

   IF KEYWORD_SET(old) THEN BEGIN

       xMod = -79.
       yMod = 296.
       zMod = -36.

   ENDIF ELSE BEGIN
       
       ; Use Revised Values:
 
       vSunLG =        306.  ; +/- 18 km/s
       lSunLG = !DTOR*  99.  ; +/- 5 deg
       bSunLG = !DTOR* (-4.) ; +/- 4 deg

       xMod = vSunLG*COS(bSunLG)*COS(lSunLG)
       yMod = vSunLG*COS(bSunLG)*SIN(lSunLG)
       zMod = vSunLG*SIN(bSunLG)

   ENDELSE

   vMod = xMod*COS(DOUBLE(l)*!DTOR)*COS(DOUBLE(b)*!DTOR) + yMod*SIN(DOUBLE(l)*!DTOR)*COS(DOUBLE(b)*!DTOR) +zMod*SIN(DOUBLE(b)*!DTOR)

   IF NOT KEYWORD_SET(reverse) THEN RETURN, vIn + vMod $
     ELSE RETURN, vIn - vMod
      
END
