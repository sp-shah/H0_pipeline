; Tests to see if points (x, y, z) are inside ellipsoid: (actually, spheroid!)
;  Long axis = a
;  Short axis = b
;  Center of ellipse at (rx,ry,rz)

;  Limitations: Axis a is aligned with direction to ellipse


FUNCTION InsideEllipsoid, x,y,z, a,b, rx,ry,rz, MINDIST=MinDist

   ; Shift center of ellipse to origin:
   x1 = x-rx
   y1 = y-ry
   z1 = z-rz

   CartesianToPolar, rx,ry,rz, r, theta, phi

   ; Rotate through -phi about z-axis:
   Rotate, -phi, X=x1, Y=y1, Z=z1, NEWX=x2, NEWY=y2, NEWZ=z2, AXIS=2

   ; Rotate through -theta about y-axis:
   Rotate, -theta, X=x2, Y=y2, Z=z2, NEWX=x3, NEWY=y3, NEWZ=z3, AXIS=1
     
   ; Now z-axis is aligned with axis a of allipsoid
   
   IF N_ELEMENTS(MinDist) GT 0 THEN BEGIN
       Dist = SQRT(x^2+y^2+z^2)
       Result = ((x3/b)^2 + (y3/b)^2 + (z3/a)^2 LT 1 AND z3 GT -Dist+MinDist) 
   ENDIF ELSE Result = ((x3/b)^2 + (y3/b)^2 + (z3/a)^2 LT 1)

   RETURN, Result

END
