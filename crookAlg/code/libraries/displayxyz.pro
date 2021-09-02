; Routine to Graph x, y, z points and spin them about the specified
; axis (default=z)

PRO DisplayXYZ, x, y, z, axis

   SET_PLOT, 'x'
   !P.MULTI=0

   NPoints = 360
   NRotations = 2

   MaxRange = SQRT(MAX(x^2+y^2+z^2))

   IF N_PARAMS() LT 4 THEN axis = 2  

   Angle = 2*!PI*FLOAT(FINDGEN(NPoints)) / NPoints

   FOR j = 1, NRotations DO BEGIN

       FOR i = 0, NPoints-1 DO BEGIN
           Rotate, Angle(i), X=x, Y=y,Z=z, NEWX=xNew, NEWY=yNew,NEWZ=zNew, AXIS=axis
           PLOT, xNew, zNew, PSYM=4, /ISOTROPIC, $
             XRANGE=[-1*MaxRange, MaxRange], YRANGE=[-1*MaxRange, MaxRange]
           
           WAIT, 0.01
       ENDFOR
   ENDFOR


END
