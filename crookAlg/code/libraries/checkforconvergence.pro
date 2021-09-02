FUNCTION CheckForConvergence, x, POCKETSIZE=N
   ; If x contains the last N_ELEMENTS(x) values
   ; test to see if it has converged

   ; If returned value is sufficiently close 
   ; to zero then convergence has occurred

   ; Split into pockets of N (=10) members -- at least 5 pockets)
   IF N_ELEMENTS(N) EQ 0 THEN N = MAX([MIN([10, FLOOR(FLOAT(N_ELEMENTS(x)) / 5)]),1])
   
   NumPockets = FLOOR(FLOAT(N_ELEMENTS(x)) / N)

   MeanVal = FLTARR(NumPockets)

   ; Find mean of each pocket

   FOR i = 0, NumPockets-1 DO BEGIN
       iStart = i * N
       iEnd = (i+1)*N - 1
       IF i EQ NumPockets-1 THEN iEnd = N_ELEMENTS(x)-1
       
       MeanVal(i) = MEAN(x(iStart:iEnd))

   ENDFOR
   
   ; Look at spacing of each pocket

   Spacing = FLTARR(NumPockets-1)
   Spacing(*) = MeanVal(1:NumPockets-1) - MeanVal(0:NumPockets-1)

   ; Compute mean spacing.

   Convergence0 = ABS(MEAN(Spacing))

   

; Alternative Method:

   ; Calc using 0.5 +/- Erf[n / Sqrt[2] ]  for n=1,2

   y1 = Percentile(x, [15.8655,84.1345])
   y2 = Percentile(x, [2.27501,97.7250])

   Convergence = 1. - (y1(1) - y1(0)) / (y2(1) - y2(0))
   
   PRINT, "Convergence Measures: ", Convergence, Convergence0

;   RETURN, Convergence
   RETURN, Convergence0
   

END
