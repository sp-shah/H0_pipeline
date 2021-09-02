; Tests to see if points (x, y, z) are inside two cones stamped
; back-to-back at large flat surface
;  Long axis = a = Dist from Center to Tip
;  Short axis = b = Radius at Center
;  Center of conoid at (rx,ry,rz)

;  Limitations: Axis a is aligned with direction to the conoid

; IF c is present, then let c be the length (c.f. a) of the negative cone

FUNCTION InsideConoid, x,y,z, a,b, rx,ry,rz, MINDIST=MinDist, C=c

   ; Shift center to origin:
   x1 = x-rx
   y1 = y-ry
   z1 = z-rz

   CartesianToPolar, rx,ry,rz, r, theta, phi

   ; Rotate through -phi about z-axis:
   Rotate, -phi, X=x1, Y=y1, Z=z1, NEWX=x2, NEWY=y2, NEWZ=z2, AXIS=2

   ; Rotate through -theta about y-axis:
   Rotate, -theta, X=x2, Y=y2, Z=z2, NEWX=x3, NEWY=y3, NEWZ=z3, AXIS=1
     
   ; Now z-axis is aligned with axis a of conoid
   ; Inside Cone if x^2 + y^2 < MAX( b^2(1-|z|/a)^2 , 0)

   Rxy2 = x3^2 + y3^2
   
   
   IF a LT 0 THEN Rmax = REPLICATE(0., N_ELEMENTS(z3)) ELSE Rmax = b*(1 - ABS(z3)/a)

   IF N_ELEMENTS(c) GT 0 THEN BEGIN
       indNegz3 = WHERE(z3 LT 0)

       IF c LE 0 THEN Rmax(indNegz3) = 0 ELSE $
         IF indNegz3(0) GE 0 THEN Rmax(indNegz3) = b*(1-ABS(z3(indNegz3))/c)
       
   ENDIF

   RmaxNeg = WHERE(Rmax LT 0)
   IF RmaxNeg(0) GE 0 THEN Rmax(RmaxNeg) = 0
   Rmax2 = Rmax^2

   Result = (Rxy2 LT Rmax2)

   IF N_ELEMENTS(MinDist) GT 0 THEN BEGIN
       Dist = SQRT(Rxy2 + z3^2)
       Result = (Result AND z3 GT -Dist+MinDist) 
   ENDIF

   RETURN, Result

END
