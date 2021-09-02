; Rotates the coordinates such that all points are centered around the
; specified points.

; If /POLE is set then it will put the center at the pole
; Otherwise it will put it at latitude=0, longitude=0

PRO CenterCoordsOnPoint, b, l, NewCenterB, NewCenterL, bNew, lNew, POLE=pole, PLOT=plot

   ; b, l in degrees

   IF N_ELEMENTS(centerl) EQ 0 THEN centerl = 0
   IF N_ELEMENTS(centerb) EQ 0 THEN centerb = 0

   RotSteps = 20

   PolarToCartesian, REPLICATE(1., N_ELEMENTS(b)), !PI/2 - b*!DTOR, l*!DTOR, x, y, z  
  
   IF KEYWORD_SET(plot) THEN BEGIN
       !P.MULTI=0
       MaxRange = SQRT(MAX(x^2+y^2+z^2))
       indPlot = WHERE(x GE 0)
       PLOT, y(indPlot), z(indPlot), PSYM=3, /ISOTROPIC, XRANGE=[-MaxRange, MaxRange], $
         YRANGE=[-MaxRange, MaxRange]
       
       yLast = y(indPlot)
       zLast = z(indPlot)

       FOR i = 0, RotSteps-1 DO BEGIN
           WAIT, 0.05
           Angle = NewCenterL * FLOAT(i+1) / (RotSteps)
           Rotate, -Angle*!DTOR, X=DOUBLE(x),Y=DOUBLE(y),Z=DOUBLE(z), NEWX=x1, NEWY=y1, NEWZ=z1, AXIS=2
           
           indPlot = WHERE(x1 GE 0)
           OPLOT, y1(indPlot), z1(indPlot), PSYM=3
           OPLOT, yLast, zLast, COL=0
           
           yLast=y1(indPlot)
           zLast=z1(indPlot)
       ENDFOR
   ENDIF

   ; After rotation, (NewCenterB, NewCenterL) should mark the POLE
   ; of the coorinate system

   ; Need 2 rotations:
   ; 1st - rotate AXES such that x'-axis lines up with centerpoint (y'=0)
   Rotate, -NewCenterL*!DTOR, X=DOUBLE(x),Y=DOUBLE(y),Z=DOUBLE(z), NEWX=x1, NEWY=y1, NEWZ=z1, AXIS=2
  
   IF KEYWORD_SET(pole) THEN BEGIN
       ; 2nd - rotate points about y-axis so
       ;       that centerpoint moves to x'=0         
       RotAngle = NewCenterB - 90.
   ENDIF ELSE BEGIN
        ; 2nd - rotate points about y-axis so that centerpoint moves to z'=0   
       RotAngle = NewCenterB
   ENDELSE
     
   IF KEYWORD_SET(plot) THEN BEGIN
       FOR i = 0, RotSteps-1 DO BEGIN
           WAIT, 0.05
           Angle = RotAngle * FLOAT(i+1) / (RotSteps)
           Rotate, Angle*!DTOR, X=x1,Y=y1,Z=z1, NEWX=x2, NEWY=y2, NEWZ=z2, AXIS=1
           indPlot = WHERE(x2 GE 0)
           OPLOT, y2(indPlot), z2(indPlot), PSYM=3
           OPLOT, yLast, zLast, COL=0
           
           yLast=y2(indPlot)
           zLast=z2(indPlot)
       ENDFOR
   ENDIF
   
   Rotate, RotAngle*!DTOR, X=x1,Y=y1,Z=z1, NEWX=x2, NEWY=y2, NEWZ=z2, AXIS=1

   CartesianToPolar, x2, y2, z2, r, theta, phi

   bNew = 90 - theta*!RADEG
   lNew = phi*!RADEG

END
