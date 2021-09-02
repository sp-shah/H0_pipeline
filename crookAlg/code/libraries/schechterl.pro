; Returns a Schechter Function Calculated for given alpha, phi0, L*

FUNCTION SchechterL, L, alpha, Phi0, LStar
   Phi = Phi0 * (L / LStar)^DOUBLE(alpha) * EXP(-DOUBLE(L/LStar)) / LStar
   RETURN, Phi
END
