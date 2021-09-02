; Fit a Function that is linear for x<<exp[p] with gradient of m, and flat
; for x>>exp[p] (using exp[p] instead of p to avoid infinities in CurveFit)

; If /ROBUST set then use CurveFit_Robust (and return "Dispersion")

; y = ( m exp[p] ) tanh( x/exp[p] )



FUNCTION TanhFit, x, y, WEIGHTS=Weights, SIGMA=Sigma, ROBUST=Robust, FITTEDDISPERSION=FittedDispersion, FULLDISPERSION=FullDispersion, NDISCARDED=nDiscarded, MINRETAIN=MinRetain

   IF N_ELEMENTS(Weights) EQ 0 THEN Weights = REPLICATE(1.0, N_ELEMENTS(x))
   
   x50 = Percentile(ABS(x), 50)
   y50 = Percentile(ABS(y), 50)
   Trialm = FLOAT(y50) / x50
   Trialp = x50

   A = [Trialm, ALOG(Trialp*1.5)]

   IF KEYWORD_SET(Robust) THEN $
     yfit = CURVEFIT_Robust(X, Y, weights, A, Sigma, FUNCTION_NAME='TanhLine', FITTEDDISP=FittedDispersion, FULLDISP=FullDispersion, NDISCARDED=nDiscarded, MINRETAIN=MinRetain) $
   ELSE yfit = CURVEFIT(X, Y, weights, A, Sigma, FUNCTION_NAME='TanhLine')

   RETURN, A

END

PRO TestTanhFit
   p = 6.
   m = 3.

   R1 = RANDOMN(seed, 1000)
   R2 = RANDOMN(seed, 1000)

   x = NumInRange(1000, -30, 30)
   y = (m*p)*TANH(x/p)

   x1 = x + R1*1.
   y1 = y + R2*1.

   plot, x1, y1, PSYM=3
   
   A = TanhFit(x1,y1)

   PRINT, A

   TanhLine, x1, A, y2
   OPLOT, x1, y2, COL=RGB(0,255,0)

END
