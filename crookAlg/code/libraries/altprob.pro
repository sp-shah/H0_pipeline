; Want P(x)*P(y) = P1 (P1 defaults to 68%)
; Given x and y are gaussianly distributed, For given x (in units of
; sigma), what is y/sigma?

FUNCTION AltProb, x, PROB=P1, SIGMA=sig

   IF N_ELEMENTS(sig) GT 0 THEN P1 = ERF(sig/SQRT(2))

   IF N_ELEMENTS(P1) EQ 0 THEN P1 = ERF(1./SQRT(2))

   ; Prob observing data more extreme than x?
   xME = 1. - ERF(ABS(x)/SQRT(2))
   
   ; Desired Probability Contour is P1 s.t. 1-P1 = yME.xME

   ; Prob y of being more extreme than y1 is yME
   yME = (1 - P1) / xME
   
   ; Therefore 1-yME equals ERF(y1/SQRT(2))
   
   y = InverseERF(1-yME) * SQRT(2)
   
   RETURN, y

END
