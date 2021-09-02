
FUNCTION AngSep, RA1, Dec1, RAList, DecList, RADIANS=radians
   ; Calculates the angular separation of a list of points 
   ; (RAlist,DecList) from the point or list of points (RA1,Dec1)
   ; RA is measured in decimal hours
   ; Dec is measured in decimal degrees
   ; Returns angle in radians (on interval [0,Pi])

   ; If /RADIANS is set, RA, Dec given in radians

   IF NOT KEYWORD_SET(radians) THEN BEGIN
       DecConv = !DTOR
       RAConv = 15*!DTOR
   ENDIF ELSE BEGIN
       DecConv = 1.
       RAConv = 1.
   ENDELSE

   ; In Cartesian Coordinates:
   z1 = SIN(DOUBLE(Dec1)*DecConv)
   r1 = COS(DOUBLE(Dec1)*DecConv)
   x1 = r1*COS(DOUBLE(RA1)*RAConv)
   y1 = r1*SIN(DOUBLE(RA1)*RAConv)

   zlist = SIN(DOUBLE(DecList)*DecConv)
   rlist = COS(DOUBLE(DecList)*DecConv)
   xlist = rlist*COS(DOUBLE(RAList)*RAConv)
   ylist = rlist*SIN(DOUBLE(RAList)*RAConv)
 
   ; Compute Dot Products 
   DotProduct = x1*xlist + y1*ylist + z1*zlist  ; (This is Cos of angle)

   RETURN, ACOS(DotProduct)

END
