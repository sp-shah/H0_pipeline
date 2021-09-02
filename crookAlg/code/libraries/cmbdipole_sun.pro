; Returns position & magnitude of dipole in CMB wrt Sun

PRO CMBDipole_Sun, CMB_L, CMB_B, CMB_V, RADIANS=radians
   ; 5-Year WMAP parameters: (Hinshaw et al 2009)
   IF KEYWORD_SET(radians) THEN s = !DTOR ELSE s = 1.0

   CMB_B = s*  48.26  ; +/- 0.03
   CMB_L = s* 263.99 ; +/- 0.14
   CMB_V =    369.0  ; +/- 0.9
END
