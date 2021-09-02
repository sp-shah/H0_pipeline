; Fit Double Power-law to a data set


PRO fitdblpowerfunc, x, coeff, F, pder

   a = coeff[0]
   b = coeff[1]
   c = coeff[2]
   r = coeff[3]

   ; Choose function of the form:
   ;     F(x) = c.x^-a           [x < r0]
   ;     F(x) = c.r^(b-a).x^-b   [x > r0]

   ; Define a procedure to return F(x), given
   ; Note that coeff is an array containing the values a, b, c, r

   indlow = WHERE(x LT r, COMPLEMENT=indhigh)

   F = DBLARR(N_ELEMENTS(x))

   IF indlow(0) GE 0 THEN BEGIN
       F(indlow) =  c * x(indlow)^(-1*a)
   ENDIF
   IF indhigh(0) GE 0 THEN BEGIN
       F(indhigh) = c * (r^(b-a)) * x(indhigh)^(-1*b)
   ENDIF

END

FUNCTION FitDblPower, xdata, ydata, WEIGHTS=weights, COEFF=coeff

   IF N_ELEMENTS(coeff) EQ 0 THEN BEGIN
       ; Provide first guess at coefficients:
       x1 = Percentile(xdata, 10, ind1)
       x2 = Percentile(xdata, 90, ind2)
       y1 = ydata(ind1)
       y2 = ydata(ind2)
       
       a = -ALOG(y1/y2)/ALOG(x1/x2)
       c = y1*x1^a
       r = SQRT(x1*x2)
       b = a

       coeff = [a,b,c,r]
       
   ENDIF

   IF N_ELEMENTS(weights) EQ 0 THEN weights = REPLICATE(1.0, N_ELEMENTS(xdata))

   yfit = CURVEFIT(xdata, ydata, weights, coeff, sigma, FUNCTION_NAME='fitdblpowerfunc',chisq=csq, /noderivative)

   fitdblpowerfunc, xdata, coeff, ytest   

;   OPLOT, xdata, ytest, COLOR = RGB(255, 0, 255), LINESTYLE = 0
stop
   RETURN, coeff

END

PRO TestDblPowerFit

   A = [1.5, 2., 10, 0.5]

   x = (FINDGEN(100) + 1) / 100
   fitdblpowerfunc, x, A, y   

   PLOT, x, y, /XLOG, /YLOG, PSYM=1

   weights = fltarr(n_elements(x))+1.

   coeff = [0.8, 2.5, 40., 0.4]
   FitDblPower, x, y, weights, coeff

END
