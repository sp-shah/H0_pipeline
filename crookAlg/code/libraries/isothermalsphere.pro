FUNCTION IsothermalSphere_Differential, r, y

    theta = y[1]
    rho = y[0]

    RETURN, [theta, -9*rho^2 - 2./r + 2*theta/rho]

END

PRO IsothermalSphere
   ; Computes the density of an isothermal sphere as a function of radius
   
   DeltaR = 0.01  ; Define the step size.

   r     = 0.0001    ; Start at center
   rho   = 1.0    ; Central Density
   theta = 0.0    ; Central density gradient
   
   y = [rho, theta]

   rMax = 100
   Nrep = CEIL(rMax / DeltaR)

   rStore = FLTARR(Nrep)
   rhoStore = FLTARR(Nrep)

   FOR i = 0, Nrep-1 DO BEGIN

       rStore(i) = r
       rhoStore(i) = y[0]

       dydx = IsothermalSphere_Differential(r,y) ; Calculate the initial derivative values

       yNext = RK4(y, dydx, r, DeltaR, 'IsothermalSphere_Differential')
       ; Integrate over the interval (0, 0.5)
       
       r = r + DeltaR
       y = yNext
       

   ENDFOR
       
   PLOT, rStore, rhoStore, /YLOG, /XLOG

   STOP

END
