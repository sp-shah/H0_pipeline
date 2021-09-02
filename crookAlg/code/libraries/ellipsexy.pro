PRO EllipseXY, a, b, theta, x, y, POINTS=N, XCENTER=xcenter, YCENTER=ycenter, ANGLERANGE=AngleRange
   ; Returns coordinates of an ellipse made from N points
   ; Semi-major axis = a, semi-minor axis = b
   ; centered at XCENTER, YCENTER

   ; i.e. (x-x0)^2/a^2 + (y-y0)^2/b^2 = 1
   ; then rotated about (x0,y0) thru theta (x->y)

   ; AngleRange = [StartAngle, EndAngle] <-- returns partial ellipse (degrees)

   IF NOT KEYWORD_SET(N) THEN N = 100
   IF NOT KEYWORD_SET(xcenter) THEN xcenter = 0
   IF NOT KEYWORD_SET(ycenter) THEN ycenter = 0
   
   IF N_ELEMENTS(AngleRange) NE 2 THEN BEGIN
       StartAngle = 0
       EndAngle = 2*!PI
   ENDIF ELSE BEGIN
       StartAngle = AngleRange(0)*!DTOR
       EndAngle = AngleRange(1)*!DTOR
   ENDELSE

   Angles = NumInRange(N, StartAngle, EndAngle)

   x1 = a * COS(Angles)
   y1 = b * SIN(Angles)

   Rotate, theta, X=x1, Y=y1, AXIS=2, NEWX=x2, NEWY=y2

   x = x2 + xcenter
   y = y2 + ycenter

END
