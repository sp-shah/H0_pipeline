FUNCTION PressSchechterMassFunc, M, n, rho, Mstar
   ; Returns the values for the Press-Schechter Mass function
   ; for chosen M, 
   ; given n, rho, M*

   gamma = 1. + (DOUBLE(n)/3)

   Nfunc = (rho / SQRT(!DPI) ) * gamma/DOUBLE(M)^2 * (M/Mstar)^(gamma/2) * $
     EXP( -DOUBLE(M/Mstar)^gamma )

   RETURN, Nfunc

END
