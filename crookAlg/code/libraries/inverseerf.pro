; Returns ERF[-1](z)

FUNCTION InverseERF, z
   COMMON InverseErf_Store, x, y, xMax

   IF N_ELEMENTS(x) EQ 0 THEN Compute = 1 ELSE Compute = 0

   ;ELSE BEGIN
   ;    IF MAX(z) GT xMax THEN BEGIN 
   ;        xMax = MAX(z)
   ;        Compute = 1
   ;    ENDIF ELSE Compute = 0
   ;ENDELSE
   
   IF Compute THEN BEGIN
       IF N_ELEMENTS(xMax) EQ 0 THEN xMax = 5.84D
       Nsample = 1000
       Xsub = NumInRange(Nsample,DOUBLE(1e-6),xMax, /LOG)
       x = DOUBLE([-1*REVERSE(Xsub), 0., Xsub])
       y = ERF(x)
   ENDIF

   RETURN, INTERPOL(x, y, z)

END
