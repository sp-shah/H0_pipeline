; I think this procedure still has flaws...



FUNCTION IntegratedSchechter, M, phi0,M0,alpha
  ; Computes the integrated Schecter function 
  ; over the given values of M

  phiInt = FLTARR(N_ELEMENTS(M))

  phiInt(0) = 0.

  Normalization = phi0*GAMMA(alpha+1)
 
  x = 10^DOUBLE(-0.4*(M-M0))
  SkipCalc = (x GT 700)
  FOR i = 1, N_ELEMENTS(M)-1 DO BEGIN 
      IF SkipCalc(i) EQ 0 THEN phiInt(i) =  (1 - IGAMMA(alpha+1, x(i))) $
      ELSE phiInt(i) = 0.
  ENDFOR

  RETURN, phiInt * Normalization

END
