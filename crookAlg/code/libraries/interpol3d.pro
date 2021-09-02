FUNCTION Interpol3D, Value, x, y, z, xNew, yNew, zNew, GRID=grid
   ; Given a set of values at grid points (Value)
   ; And the locations of the grid points x, y, z

   ; Compute interpolated values at xNew, yNew, zNew
   ; Values must be a 3D array of vectors Value(xInd, yInd, zInd, i) = Val(i)
   ; And x, y, z are arrays of length xMax, yMax, zMax
   ; And Value is Array of size (xMax, yMax, zMax, *)

   ; If /GRID is set then compute values at all combinations of 
   ; xNew, yNew, zNew and return an an array of size Nx x Ny x Nz
  
   IF KEYWORD_SET(grid) THEN BEGIN
       GridPoints, xNew, yNew, zNew, xNewVal, yNewVal, zNewVal
   ENDIF ELSE BEGIN
       xNewVal = xNew
       yNewVal = yNew
       zNewVal = zNew
   ENDELSE

   ; Find Values of nearest grid points that are equal
   ; to or greater than values of xNew, yNew

;stop

   xAbove = FindLargerValues( x, xNewVal )
   yAbove = FindLargerValues( y, yNewVal )
   zAbove = FindLargerValues( z, zNewVal )

   xBelow = xAbove - 1
   yBelow = yAbove - 1
   zBelow = zAbove - 1

   xNegInd = WHERE(xBelow LT 0 AND x(xAbove) EQ xNewVal)
   IF xNegInd(0) GE 0 THEN BEGIN
       xBelow(xNegInd) = 0
       xAbove(xNegInd) = 1       
   ENDIF

   yNegInd = WHERE(yBelow LT 0 AND y(yAbove) EQ yNewVal)
   IF yNegInd(0) GE 0 THEN BEGIN
       yBelow(yNegInd) = 0
       yAbove(yNegInd) = 1       
   ENDIF

   zNegInd = WHERE(zBelow LT 0 AND z(zAbove) EQ zNewVal)
   IF zNegInd(0) GE 0 THEN BEGIN
       zBelow(zNegInd) = 0
       zAbove(zNegInd) = 1       
   ENDIF

   ; Output array to allow for Value to be a Vector
   NewValue = DBLARR(N_ELEMENTS(xNewVal),N_ELEMENTS(Value(0,0,0,*)))

   FOR i = 0, N_ELEMENTS(Value(0,0,0,*))-1 DO BEGIN
       Value0 = Value(*,*,*,i)

                                ; Compute x value that want to interpolate Y at:
       
       ValYAboveZAbove = (Value0(xBelow,yAbove,zAbove)*(x(xAbove)-xNewVal) + $
                          Value0(xAbove,yAbove,zAbove)*(xNewVal-x(xBelow))) / (x(xAbove) - x(xBelow))
       
       ValYBelowZAbove = (Value0(xBelow,yBelow,zAbove)*(x(xAbove)-xNewVal) + $
                          Value0(xAbove,yBelow,zAbove)*(xNewVal-x(xBelow))) / (x(xAbove) - x(xBelow))
       
                                ; Now Point in x-y plane for above z
       
       ValZAbove = (ValYBelowZAbove*(y(yAbove)-yNewVal) + $
                    ValYAboveZAbove*(yNewVal-y(yBelow))) / (y(yAbove) - y(yBelow))
       
                                ; Now, go back and do it again for the lower z
       
                                ; Compute x value that want to interpolate Y at:
       
       ValYAboveZBelow = (Value0(xBelow,yAbove,zBelow)*(x(xAbove)-xNewVal) + $
                          Value0(xAbove,yAbove,zBelow)*(xNewVal-x(xBelow))) / (x(xAbove) - x(xBelow))
       
       ValYBelowZBelow = (Value0(xBelow,yBelow,zBelow)*(x(xAbove)-xNewVal) + $
                          Value0(xAbove,yBelow,zBelow)*(xNewVal-x(xBelow))) / (x(xAbove) - x(xBelow))
       
                                ; Now Point in x-y plane for above z
       
       ValZBelow = (ValYBelowZBelow*(y(yAbove)-yNewVal) + ValYAboveZBelow*(yNewVal-y(yBelow))) / (y(yAbove) - y(yBelow))
       
                                ; Now use values on 2 planes to find final value
       
       NewValue(*,i) = (ValZBelow*(z(zAbove)-zNewVal) + ValZAbove*(zNewVal - z(zBelow))) / (z(zAbove) - z(zBelow))
       
   ENDFOR

   IF KEYWORD_SET(grid) THEN BEGIN

       UnGridPoints, xNewVal, yNewVal, zNewVal, x1, y1, z1, $
         GRIDVALUE=NewValue, NEWVALUE=FinalValue

;       FinalValue = FLTARR(N_ELEMENTS(xNew), N_ELEMENTS(yNew), N_ELEMENTS(zNew))
;       FOR k = 0, N_ELEMENTS(zNew)-1  DO BEGIN
;           FOR j = 0, N_ELEMENTS(yNew) - 1 DO BEGIN
;               FOR i = 0, N_ELEMENTS(xNew) -1 DO BEGIN
;                   count = i + N_ELEMENTS(xNew)*j + $
;                     N_ELEMENTS(yNew)*N_ELEMENTS(xNew)*k
;                   FinalValue(i, j, k) = NewValue(count)
;               ENDFOR
;           ENDFOR
;       ENDFOR

   ENDIF ELSE FinalValue = NewValue

   RETURN, FinalValue

END

PRO TestInterpol3D
   ; Short procedure designed to test the above function

   N = 10

   x = NumInRange(N,-2,2)
   y = NumInRange(N,-5,5)
   z = NumInRange(N,-1,1)
   
   GridPoints, x, y, z, xGrid, yGrid, zGrid

   f = EXP( -(xGrid^2 + yGrid^2 + zGrid^2) )
   col = ColorScale([255,0,0], [0,255,0], f)
   
   PRINT, MAX(abs(f)), MIN(abs(f))

;   col = 255* ABS(f) / MAX(ABS(f))

   UnGridPoints, xGrid, yGrid, zGrid, x1, y1, z1, GRIDVALUE=f, NEWVALUE=f3D
   UnGridPoints, xGrid, yGrid, zGrid, x1, y1, z1, GRIDVALUE=col, NEWVALUE=col3D

   SHADE_SURF, 255*ABS(f3D(*,*,0)) / MAX(ABS(f)), x1, y1

   PressEnter, "ENTER to spin"

   Spin3D, xGrid, yGrid, zGrid, COL=col, duration=1

   PressEnter, "ENTER to interpolate"

   N2 = 15
   xNew = NumInRange(N2,-1,1)
   yNew = NumInRange(N2,-1,1)
   zNew = NumInRange(N2,-1,1)

   NewCol3D = Interpol3D(col3D, x, y, z, xNew, yNew, zNew, /GRID)
   Newf3D = Interpol3D(f3D, x, y, z, xNew, yNew, zNew, /GRID)

   SHADE_SURF, 255*ABS(Newf3D(*,*,0)) / MAX(ABS(f)), xNew, yNew

   GridPoints, xNew, yNew, zNew, xGridNew, yGridNew, zGridNew, VALUE=Newf3D, NEWVALUE=Newf

   PRINT, MAX(ABS(f)), MIN(ABS(f))
   NewColf = ColorScale([255,0,0], [0,255,0], Newf)
 
   PressEnter, "ENTER to spin"

   Spin3D, xGridNew, yGridNew, zGridNew, COL=NewColf, duration=30

   STOP

END
