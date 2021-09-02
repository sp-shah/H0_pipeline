; Returns psoition & magnitude of dipole in CMB
PRO CMBDipole, CMB_L, CMB_B, CMB_V, LS=LS
   ; Erdogdu et al 2006 paper:
;   CMB_B = 29.
;   CMB_L = 273.
;   CMB_V = 627.

   ; 621.6 km/s towards 28.51, 272.31

   CMB_B = 28.51
   CMB_L = 272.31
   CMB_V = 621.6

   IF KEYWORD_SET(LS) THEN BEGIN
       CMB_B = 27.
       CMB_L = 270.
       CMB_V = 627.       
   ENDIF

END
