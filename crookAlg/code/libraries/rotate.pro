PRO Rotate, theta, X=x, Y=y,Z=z, NEWX=xNew, NEWY=yNew, NEWZ=zNew, AXIS=rotateaxis
   ; Rotates points x, y, [z] about axis=0,1,2 (=x,y,z) [default=z] anticlockwise
   ; Not required to provide the values corresponding to the axis of rotation
   ; e.g. if rotate about z, don't need to provide z-values

   ; Can either use singel value fo theta & phi, or same no. of theta's as x's.

   IF N_ELEMENTS(rotateaxis) EQ 0 THEN rotateaxis=2

   IF rotateaxis EQ 0 THEN BEGIN
       ; Rotate about x
       IF N_ELEMENTS(x) GT 0 THEN xNew = x
       yNew = y*COS(theta) - z*SIN(theta)
       zNew = z*COS(theta) + y*SIN(theta)
   ENDIF
   IF rotateaxis EQ 1 THEN BEGIN
       ; Rotate about y
       IF N_ELEMENTS(y) GT 0 THEN yNew = y
       xNew = x*COS(theta) + z*SIN(theta)
       zNew = z*COS(theta) - x*SIN(theta)
   ENDIF
   IF rotateaxis EQ 2 THEN BEGIN
       ; Rotate about z
       IF N_ELEMENTS(z) GT 0 THEN zNew = z
       xNew = x*COS(theta) - y*SIN(theta)
       yNew = y*COS(theta) + x*SIN(theta)
   ENDIF

END
