PRO SmoothedScatter, x, y, NumBins
                                ; Generate a smoothed scatter plot
                                ; using equal numbers of points (in
                                ; x-direction) to average together

   IF N_ELEMENTS(NumBins) EQ 0 THEN NumBins = 20

   NumberPerBin = CEIL(FLOAT(N_ELEMENTS(x)) / NumBins)

   BinEqualNumber, x, NumberPerBin, BinMean, BinWidth, BinStdDev, NumInBin, REVERSE=reverse, BINSTART=BinStart, BINEND=BinEnd, SMALLLASTBIN=SmallLastBin, WEIGHT=weight


   Npoints = N_ELEMENTS(BinStart)

   xVal = FLTARR(Npoints)
   yVal = FLTARR(Npoints)
   xErr = FLTARR(Npoints)
   yErr = FLTARR(Npoints)


   FOR i = 0, Npoints-1 DO BEGIN
       InBin = WHERE(x GE BinStart(i) AND x LT BinEnd(i))
       xVal(i) = MEAN(x(InBin))
       yVal(i) = MEAN(y(InBin))
       xErr(i) = STDDEV(x(InBin))
       yErr(i) = STDDEV(y(InBin))
   ENDFOR

   EnhancedPlot, xVal, yVal, XERR=xErr, YERR=yErr

END
