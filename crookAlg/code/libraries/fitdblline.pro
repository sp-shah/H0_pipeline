; Fit a Double Line (2 slopes) to data

PRO fitdbllinefunc, x, coeff, F, pder

   m = coeff[0]
   n = coeff[1]
   c = coeff[2]
   r = coeff[3]

   ; Choose function of the form:
   ;     F(x) = -mx + c           [x < r]
   ;     F(x) = -nx + (n-m)r + c  [x > r]

   ; Define a procedure to return F(x), given
   ; Note that coeff is an array containing the values a, b, c, r

   indlow = WHERE(x LT r, COMPLEMENT=indhigh)

   F = DBLARR(N_ELEMENTS(x))

   IF indlow(0) GE 0 THEN BEGIN
       F(indlow) = -1*m * x(indlow) + c
   ENDIF
   IF indhigh(0) GE 0 THEN BEGIN
       F(indhigh) = -1*n * x(indhigh) + (n-m)*r + c
   ENDIF

END

FUNCTION FitDblLine, xdata, ydata, WEIGHTS=weights, COEFF=coeff, SIGMA=sigma, PLOT=overplot

   ; /PLOT Overplots the line

   IF N_ELEMENTS(coeff) EQ 0 THEN BEGIN
       ; Provide first guess at coefficients:
       x1 = Percentile(xdata, 10, ind1)
       x2 = Percentile(xdata, 50, ind2)
       x3 = Percentile(xdata, 90, ind3)
       y1 = ydata(ind1)
       y2 = ydata(ind2)
       y3 = ydata(ind3)

       m = -(y1-y2)/(x1-x2)
       c = y1+m*x1
       r = x2
       n = -(y2-y3)/(x2-x3)
 
       coeff = [m,n,c,r]
       
   ENDIF

   IF N_ELEMENTS(weights) EQ 0 THEN weights = REPLICATE(1.0, N_ELEMENTS(xdata))

   yfit = CURVEFIT(xdata, ydata, weights, coeff, sigma, FUNCTION_NAME='fitdbllinefunc',chisq=csq, /noderivative)

   IF KEYWORD_SET(overplot) THEN BEGIN
       fitdbllinefunc, xdata, coeff, ytest   
       OPLOT, xdata, ytest, COLOR = RGB(0, 255, 0), LINESTYLE=0
       STOP
   ENDIF

   RETURN, coeff

END
