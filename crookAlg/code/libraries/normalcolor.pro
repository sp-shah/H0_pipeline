FUNCTION NormalColor, ColMin, ColMax, x, XMIN=xMin, XMAX=xMax, $
                      CBCOLORS=CBcolors, POSITIVE=positive, CBNUMCOLS=Ncbcols
   ; Normally distribute colours (more variation near 0)
   ; Centered on Mean of x. recalibrated to 1 stddev
   ; Array same size as x returned, with correspondig colors

   ; Also returns an array of 100 colours uniformly distributed throughout
   ; range of x [xMin, xmax]

   ; If /POSITIVE is set, then only +ve half of Distribution is considered

   ERF95 = 1.3859  ; Erf(ERF95) = 0.95
   
   IF N_ELEMENTS(Ncbcols) EQ 0 THEN Ncbcols = 256

   ColRange = ColMax - ColMin
   ColMid = FLOAT(ColMin + ColMax)/2

   IF KEYWORD_SET(positive) THEN BEGIN
       xMean = 0.
       xStdDev = SQRT(TOTAL(x^2) / (N_ELEMENTS(x)-1))
       xScaled = ABS(x) / xStdDev
   ENDIF ELSE BEGIN
       xMean = MEAN(x)
       xStdDev = STDDEV(x)
       xScaled = (x - xMean) / xStdDev
   ENDELSE
   

   ; Scale this s.t. ERF1(xMax) = 0.95
   IF KEYWORD_SET(xMax) THEN BEGIN
       ScaleMax = (xMax - xMean) / xStdDev
       ScaleMin = (xMin - xMean) / xStdDev
   ENDIF ELSE BEGIN
       ScaleMax = MAX(xScaled)
       ScaleMin = MIN(xScaled)
   ENDELSE

   MaxScale = MAX([ABS(ScaleMax), ABS(ScaleMin)])
   k = ERF95/MaxScale

   IF KEYWORD_SET(positive) THEN BEGIN
       NormalColors = ERF(k*xScaled) * FLOAT(ColRange)/0.95 + ColMin
   ENDIF ELSE BEGIN
       NormalColors = ERF(k*xScaled) * FLOAT(ColRange)/(2*0.95) + ColMid
   ENDELSE
   
   IF N_ELEMENTS(xMin) GT 0 THEN BEGIN
       CBx = (xMax-xMin)*FINDGEN(NcbCols) / (NcbCols-1) + xMin
       CBxScaled = (CBx - xMean) / xStdDev

       IF KEYWORD_SET(positive) THEN BEGIN
           CBcolors = ERF(k*CBxScaled) * FLOAT(ColRange)/0.95 + ColMin
       ENDIF ELSE BEGIN
           CBcolors = ERF(k*CBxScaled) * FLOAT(ColRange)/(2*0.95) + ColMid
       ENDELSE

   ENDIF

   RETURN, NormalColors

END
