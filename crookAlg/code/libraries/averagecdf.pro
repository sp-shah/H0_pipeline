
; Input 2 CDFs (CDF0, CDF1)
; Input Linear Weight between the 2. E.g. 0=CDF0, 1=CDF1, 0.5=Mean
; Returns Abscissa values and Data points for resulting CDF


PRO AverageCDF, X0, CDF0, X1, CDF1, Weight, X, CDF
   
   ; Set Abscissa values:
   abscissa = [X0,X1]
   abscissa_sorted = abscissa(SORT(abscissa))
   X = abscissa_sorted(RemoveDuplicate(abscissa_sorted))

   CDF0I = INTERPOL(CDF0,X0,X)
   CDF1I = INTERPOL(CDF1,X1,X)
  
   SetTo, WHERE(CDF0I LT 0), CDF0I, 0.
   SetTo, WHERE(CDF1I LT 0), CDF1I, 0.
   SetTo, WHERE(CDF0I GT MAX(CDF0)), CDF0I, MAX(CDF0)
   SetTo, WHERE(CDF1I GT MAX(CDF1)), CDF1I, MAX(CDF1)

   CDF = FLOAT(CDF0I) + FLOAT(CDF1I-CDF0I) * Weight

END
