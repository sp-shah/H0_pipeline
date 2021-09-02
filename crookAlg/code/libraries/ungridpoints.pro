PRO UnGridPoints, xGrid, yGrid, zGrid, x, y, z, GRIDVALUE=GridValue, NEWVALUE=NewValue, ANYORDER=AnyOrder
   ; Does the reverse of GridPoints

   ; xGrid, yGrid, zGrid are 1-D arrays of length SideX*SideY*SideZ
   ; Returns x,y,z each of length SideN

   ; If GridValue is present it must be a 1- or 2-D array with value
   ; corresponding to xGrid, yGrid, zGrid of same index
   ; NewValue will then be a 4-D array with Value(x,y,z, *)

   ; If zGrid is zero, a 2-D array is returned instead

   ; If /ANYORDER is set, it doesn't assume the order of the GridArrays

   x = RemoveDuplicate(xGrid, /RETURNVALUES, FREQUENCY=xFreq)
   y = RemoveDuplicate(yGrid, /RETURNVALUES, FREQUENCY=yFreq)
   
   IF N_ELEMENTS(zGrid) NE N_ELEMENTS(xGrid) THEN BEGIN
       z = 0
       Use2D = 1
   ENDIF ELSE BEGIN
       Use2D = 0
       z = RemoveDuplicate(zGrid, /RETURNVALUES, FREQUENCY=zFreq)
   ENDELSE
   
   Nx = N_ELEMENTS(x)
   Ny = N_ELEMENTS(y)
   Nz = N_ELEMENTS(z)

   IF N_ELEMENTS(GridValue) GT 0 THEN BEGIN
       IF Use2D THEN NewValue = FLTARR(Nx,Ny, N_ELEMENTS(GridValue(0,*))) ELSE NewValue = FLTARR(Nx,Ny,Nz, N_ELEMENTS(GridValue(0,*)))
   ENDIF
   
   IF KEYWORD_SET(AnyOrder) AND N_ELEMENTS(GridValue) GT 0 THEN BEGIN
       
       FOR p = 0L, N_ELEMENTS(xGrid)-1 DO BEGIN
           
           xInd = WHERE(x EQ xGrid(p))
           yInd = WHERE(y EQ yGrid(p))
           
           IF Use2D THEN NewValue(xInd(0),yInd(0), *) = GridValue(p, *) ELSE BEGIN
               zInd = WHERE(z EQ zGrid(p))
               NewValue(xInd(0),yInd(0),zInd(0), *) = GridValue(p, *)
           ENDELSE

       ENDFOR   

   ENDIF ELSE IF N_ELEMENTS(GridValue) GT 0 THEN BEGIN
       zLoop = N_ELEMENTS(GridValue(0,*))
       
       FOR k = 0L, Nz-1  DO BEGIN
           FOR j = 0L, Ny-1 DO BEGIN
               i = LINDGEN(Nx)
;               FOR i = 0L, Nx-1 DO BEGIN
               
               count = i + N_ELEMENTS(x)*j + N_ELEMENTS(y)*N_ELEMENTS(x)*k
               
                                ; Just to make sure it's all as expected
;                   IF x(i) NE xGrid(count) OR y(j) NE yGrid(count) THEN STOP
;                   IF NOT Use2D THEN IF z(k) NE zGrid(count) THEN STOP
               
;                   IF N_ELEMENTS(GridValue) GT 0 THEN BEGIN
               FOR l = 0, zLoop-1 DO BEGIN
                   IF Use2D THEN NewValue(i,j,l) = GridValue(count, l) $
                   ELSE NewValue(i,j,k,l) = GridValue(count, l)
;                   ENDIF
                   
               ENDFOR
           ENDFOR
       ENDFOR
      
   ENDIF


END
