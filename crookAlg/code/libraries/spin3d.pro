PRO SetUpAxes, MaxRange
   PLOT, [0],[0], /NODATA, $
     XRANGE=[-MaxRange,MaxRange], YRANGE=[-MaxRange,MaxRange], $
     XSTYLE=4, YSTYLE=4, /ISOTROPIC
END

PRO Spin3D, x0, y0, z0, COLOR=col0, THETA=theta, PHI=phi, PSI=psi, DURATION=duration, REDRAW=redraw, LOWRES=lowres, FINALANGLE=FinalAngle

   ; Allows visualization of 3D data points
   ; DURATION=5 is 5 seconds
   ; DURATION=0 waits for keypress
   ; /REDRAW forces clear & re-plot between each phase.
   ; /LOWRES resamples the values to a 10 x 10 x 10 grid
  
   ReducedResPoints = 2000

   IF N_ELEMENTS(theta) EQ 0 THEN theta = 30*!PI/180
   IF N_ELEMENTS(phi) EQ 0 THEN phi = 60*!PI/180
   IF N_ELEMENTS(psi) EQ 0 THEN psi = 30*!PI/180

   IF N_ELEMENTS(duration) EQ 0 THEN duration = 5

   ; Re-center:
   x = x0 - MEAN(x0)
   y = y0 - MEAN(y0)
   z = z0 - MEAN(z0)
   
   col = col0

   IF KEYWORD_SET(lowres) AND N_ELEMENTS(x0) GT ReducedResPoints THEN BEGIN
;       indResample = ROUND(NumInRange(ReducedResPoints, 0, N_ELEMENTS(x0)-1))
       indResample = ROUND(RANDOMU(seed, ReducedResPoints) * N_ELEMENTS(x0))

       x = x(indResample)
       y = y(indResample)
       z = z(indResample)
       col = col(indResample)
   ENDIF



   MaxRange = SQRT(MAX(x^2+y^2+z^2))

   RedrawInterval = 0.01

   AngleInterval = (2*!PI) / 200

   Angle = 0.

   USERSYM_CIRCLE, /FILL
   i = LONG(0)

   StartTime = SYSTIME(1)
   
   InitialPlot = 1

   SetUpAxes, MaxRange

   EmptyKeyboardBuffer
   Cont = 1

   WHILE Cont EQ 1 DO BEGIN

       Cont = (SYSTIME(1) LT StartTime + Duration) OR $
         (Duration EQ 0 AND GET_KBRD(0) EQ "")

       If NOT Cont THEN SetUpAxes, MaxRange

       Angle = (Angle + AngleInterval ) MOD (4*!PI)
       EulerRotate, x, y, z, xnew, ynew, znew, Angle, Angle/2, psi
       EnhancedPLOT, xnew, ynew, PSYM=4, COLOR=col, SYMSIZE=0.5, /OPLOT

       WAIT, RedrawInterval

       IF KEYWORD_SET(redraw) THEN BEGIN
           SetUpAxes, MaxRange
       ENDIF ELSE BEGIN
           IF NOT InitialPlot AND Cont THEN BEGIN
               OPLOT, xold, yold, PSYM=4, SYMSIZE=0.5, COL=0
           ENDIF ELSE InitialPlot = 0
       ENDELSE

       xold = xnew
       yold = ynew
   ENDWHILE    

   FinalAngle = Angle

END


PRO TestSpin3D

   ; Short procedure designed to test the above function

   N = 8

   x = NumInRange(N,-1,1)
   y = NumInRange(N,-1,1)
   z = NumInRange(N,-1,1)

   GridPoints, x, y, z, xGrid, yGrid, zGrid

   f = EXP( -(xGrid^2 + yGrid^2 + zGrid^2) )

   col = ColorScale([255,0,0], [0,255,0], f)

   Spin3D, xGrid, yGrid, zGrid, COL=col, duration=0

END
