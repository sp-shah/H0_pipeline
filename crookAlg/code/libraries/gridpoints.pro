PRO GridPoints, x, y, z, xNew, yNew, zNew, VALUE=Value, NEWVALUE=NewValue
   ; Returns three arrays of N_ELEMENTS(x)*N_ELEMENTS(y)*N_ELEMENTS(z)
   ; in size with all combinations of x, y, z

   ; If Value is present it must be a 3-D array with Value(x,y,z)
   ; NewValue will then be a 1-D array with corresponding Value in it

       
   xNew = FLTARR(N_ELEMENTS(x)*N_ELEMENTS(y)*N_ELEMENTS(z))
   yNew = FLTARR(N_ELEMENTS(x)*N_ELEMENTS(y)*N_ELEMENTS(z))
   zNew = FLTARR(N_ELEMENTS(x)*N_ELEMENTS(y)*N_ELEMENTS(z))

   IF N_ELEMENTS(Value) GT 0 THEN $
     NewValue = FLTARR(N_ELEMENTS(x)*N_ELEMENTS(y)*N_ELEMENTS(z), N_ELEMENTS(Value(0,0,0,*)))
   
   iGen = LINDGEN(N_ELEMENTS(x))

   FOR k = 0, N_ELEMENTS(z)-1  DO BEGIN
       FOR j = 0, N_ELEMENTS(y) - 1 DO BEGIN
;           FOR i = 0, N_ELEMENTS(x) -1 DO BEGIN

;               count = i + N_ELEMENTS(x)*j + N_ELEMENTS(y)*N_ELEMENTS(x)*k
               count = iGen + N_ELEMENTS(x)*j + N_ELEMENTS(y)*N_ELEMENTS(x)*k

               xNew(count) = x(iGen)
;               xNew(count) = x(i)
               yNew(count) = y(j)
               zNew(count) = z(k)

               IF N_ELEMENTS(Value) GT 0 THEN NewValue(count,*) = Value(iGen,j,k,*)
;               IF N_ELEMENTS(Value) GT 0 THEN NewValue(count,*) = Value(i,j,k,*)
               
;           ENDFOR
       ENDFOR
   ENDFOR
 
END
