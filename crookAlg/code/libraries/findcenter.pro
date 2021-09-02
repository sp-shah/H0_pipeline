; Procedure to find the center of a group of objects given RA, Dec
; Returns RA, Dec of Centre. 
; Also returns the Root-Mean-Square offset from centre in radians
; and Maximum offset in radians

PRO FindCenter, RAList, DecList, CenterRA, CenterDec, RMSOffset, MAXOFFSET=MaxOffset
   ; Compute x, y, z coordinates as if
   ; points are on the surface of a unit sphere

   zlist = SIN(DecList*!DTOR)
   rlist = COS(DecList*!DTOR)
   xlist = rlist*COS(RAList*15*!DTOR)
   ylist = rlist*SIN(RAList*15*!DTOR)
   
   xavg = MEAN(xlist)
   yavg = MEAN(ylist)
   zavg = MEAN(zlist)
   CenterDist = SQRT(xavg^2+yavg^2+zavg^2)

   ; Distance Squared from each point to centre
   sqSep = (xlist-xavg)^2 + (ylist-yavg)^2 + (zlist-zavg)^2

   ; But we only want the tangential distance
   ; Therefore subtract off square of Distance along LoS (l)
   l = (xavg*xlist + yavg*ylist + zavg*zlist) / CenterDist - CenterDist

   TangSep = SQRT(sqSep - l^2)

   ; Convert to Angle:
   theta = ASIN(TangSep) ; Angle in radians
   RMSOffset = SQRT(MEAN((theta^2)))
   MaxOffset = MAX(theta)
   
   CenterRA = (!RADEG/15)*ATAN(yavg/xavg)

   IF xavg LT 0 THEN CenterRA = CenterRA + 12.
   IF CenterRA LT 0 THEN CenterRA = CenterRA + 24.

   CenterDec = !RADEG*ATAN(zavg / SQRT(xavg^2 + yavg^2))

END
