FUNCTION deVauCouleurs, R, R0, I0
   ; Returns a function of form
   ; I = I0 * EXP(-7.67[(R/R0)^0.25  1])

   RETURN, I0 * EXP(-7.67*(DOUBLE(R/R0)^0.25 - 1))

END
