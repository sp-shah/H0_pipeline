FUNCTION HelioToLS, vIn, b, l, REVERSE=reverse, OLD=old
   ; Converts Heliocentric velicities to Local-Sheet-centric ones
   ; See Tully (2008)
   ; /REVERSE will convert vLS to vHel
         
 
   vSunLS =        318.         ; +/- 20 km/s
   lSunLS = !DTOR*  95.         ; +/- 4 deg
   bSunLS = !DTOR* (-1.)        ; +/- 4 deg

   xMod = vSunLS*COS(bSunLS)*COS(lSunLS)
   yMod = vSunLS*COS(bSunLS)*SIN(lSunLS)
   zMod = vSunLS*SIN(bSunLS)


   vMod = xMod*COS(DOUBLE(l)*!DTOR)*COS(DOUBLE(b)*!DTOR) + yMod*SIN(DOUBLE(l)*!DTOR)*COS(DOUBLE(b)*!DTOR) +zMod*SIN(DOUBLE(b)*!DTOR)

   IF NOT KEYWORD_SET(reverse) THEN RETURN, vIn + vMod $
     ELSE RETURN, vIn - vMod
      
END
