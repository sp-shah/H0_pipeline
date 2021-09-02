; Tests to see if points (x, y) are inside ellipse given by a, b, theta

FUNCTION InsideEllipse, x, y, a, b, theta, XCENTER=xCenter, YCENTER=yCenter
   IF N_ELEMENTS(theta) EQ 0 THEN theta = 0
   IF N_ELEMENTS(xCenter) EQ 0 THEN xCenter = 0
   IF N_ELEMENTS(yCenter) EQ 0 THEN yCenter = 0
   
   ; Rotate Points (x,y) through -theta about (CenterX, CenterY)
   Rotate, -theta, X=(x-xCenter), Y=(y-yCenter), NEWX=newx, NEWY=newy
   Result = ((newX/a)^2 + (newY/b)^2 LT 1)

   RETURN, Result

END
