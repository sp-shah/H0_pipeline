; /POISSONERR sets poisson erros for percetile plots

PRO AverageScatter, x, y, XAVG=xAvg, YAVG=yAvg, NUMBINS=NumBins, BINSIZE=BinSize, NUMPERBIN=NumPerBin, LOGARITHMIC=logarithmic, PERCENTILE=plotpercentile, OPLOT=oplot, LINESTYLE=linestyle, MINPERBIN=MinPerBin, PSYM=psym, YMEDIAN=ymedian, YPERCENTILE=ypercentile, NUMINBIN=NumInBin,POISSONERR=PoissonErr, _EXTRA=extra
   ; Generate a smoothed scatter plot using equal bin size (in
   ; x-direction) to average together

   ; Specify either BinSize or NumBins
   ; /LOG can be used with NumBins

   ; If Percentile is given, plot y values at upper and lower percentiles
   ;  instead of scatter plot (show a line)

   ; MinPerBin forces a minimum number of galaxies in each bin
   ; removing bins as necessary (default = 2)

   ; /YMEDIAN to use median y-value instead of mean (or set ypercentile)

   IF N_ELEMENTS(MinPerBin) EQ 0 THEN MinPerBin = 2

   IF N_ELEMENTS(NumPerBin) GT 0 THEN BEGIN
       Result = BinEqualNum(x, NumPerBin, NUMINBIN=NumInBin, BINWIDTH=BinWidth,  /LARGELASTBIN)
       NumBins = N_ELEMENTS(BinWidth)
       BinStart = FLTARR(NumBins)
       BinEnd = BinStart
       BinStart(0) = MIN(x)
       FOR i = 0, NumBins-2 DO $
         BinStart(i+1) = BinStart(i) + BinWidth(i)
       
       BinEnd = [BinStart(1:N_ELEMENTS(BinStart)-1), MAX(x)]

   ENDIF ELSE BEGIN

       IF N_ELEMENTS(NumBins) EQ 0 AND N_ELEMENTS(BinSize) EQ 0 THEN NumBins = 15
       
       IF N_ELEMENTS(BinSize) EQ 0 THEN BinSize = (MAX(x) - MIN(x)) / NumBins ELSE $
         IF N_ELEMENTS(NumBins) EQ 0 THEN NumBins = CEIL(FLOAT(MAX(x) - MIN(x)) / BinSize)

       BinPoints = NumInRange(NumBins+1, MIN(x), MIN(x)+BinSize*(NumBins+1), LOGARITHMIC=logarithmic)
       BinStart = BinPoints(0:NumBins-1)
       BinEnd = BinPoints(1:NumBins)
   ENDELSE

   NumInBin = FLTARR(NumBins)


   ; First Pass - count number per bin & adjust bin sizes as necessary:

   Npoints = NumBins

   i = 0
   WHILE i LT Npoints DO BEGIN

       IF i LT Npoints-1 THEN $
         InBin = WHERE(x GE BinStart(i) AND x LT BinEnd(i) AND FINITE(y)) $
       ELSE InBin = WHERE(x GE BinStart(i) AND FINITE(y))
       
       IF WhereSize(InBin) LT MinPerBin THEN BEGIN
           ; Not enough in bin
           IF i EQ 0 THEN BEGIN
               PRINT, "Too few objects in first bin - Ignoring..."
               i++
;               STOP
           ENDIF ELSE BEGIN
                                ; Merge bin with previous bin
               BinStart = DeleteArrayElement(BinStart, i)
               BinEnd = DeleteArrayElement(BinEnd, i-1)
               Npoints--
                                ; Recompute bin
           ENDELSE
       ENDIF ELSE i++
       
   ENDWHILE

   IF N_ELEMENTS(plotpercentile) GT 0 THEN BEGIN
       IF N_ELEMENTS(linestyle) EQ 0 THEN $
         IF N_ELEMENTS(linestyle) EQ 1 THEN linestyle=REPLICATE(linestyle, N_ELEMENTS(plotpercentile)) ELSE linestyle=REPLICATE(0, N_ELEMENTS(plotpercentile))

   ENDIF

   xVal = FLTARR(Npoints)
   yVal = FLTARR(Npoints)
   xErr = FLTARR(Npoints)
   yErr = FLTARR(Npoints)

   IF N_ELEMENTS(plotpercentile) GT 0 THEN $
     yPercentile = FLTARR(Npoints, N_ELEMENTS(plotpercentile))
  
   ValuePresent = INTARR(Npoints)

   FOR i = 0, Npoints-1 DO BEGIN
       IF i LT Npoints-1 THEN $
         InBin = WHERE(x GE BinStart(i) AND x LT BinEnd(i) AND FINITE(y)) $
       ELSE InBin = WHERE(x GE BinStart(i) AND FINITE(y))

       NumInBin(i) = WhereSize(InBin)

       IF InBin(0) GE 0 THEN BEGIN

           IF N_ELEMENTS(InBin) GE MinPerBin THEN BEGIN
               xVal(i) = MEAN(x(InBin))

               IF KEYWORD_SET(yMedian) THEN yVal(i) = MEDIAN(y(InBin)) $
               ELSE IF N_ELEMENTS(percentile) GT 0 THEN yVal(i) = Percentile(y(InBin), percentile) $
               ELSE yVal(i) = MEAN(y(InBin))
               
               ValuePresent(i) = 1
               
               IF N_ELEMENTS(plotpercentile) GT 0 THEN BEGIN
                   yPercentile(i,*) = Percentile(y(InBin), plotpercentile)
                  
               ENDIF
                   
               

               IF N_ELEMENTS(InBin) GE 2 THEN BEGIN
                   xErr(i) = STDDEV(x(InBin))
                   yErr(i) = STDDEV(y(InBin))
               ENDIF

           ENDIF ELSE BEGIN

               PRINT, "Too few objects in bin #", i
              
           ENDELSE

       ENDIF

   ENDFOR

   indRetain = WHERE(ValuePresent EQ 1)

   IF N_ELEMENTS(plotpercentile) GT 0 THEN BEGIN

       EnhancedPlot, xVal(indRetain), yPercentile(indRetain, 0), XSTYLE=1, YRANGE=[MIN(yPercentile(indRetain,*)), MAX(yPercentile(indRetain,*))], OPLOT=oplot, LINESTYLE=linestyle(0), PSYM=psym, _EXTRA=extra

       

       FOR i = 1, N_ELEMENTS(plotpercentile)-1 DO BEGIN
           EnhancedPlot, xVal(indRetain), yPercentile(indRetain,i), /OPLOT, LINESTYLE=linestyle(i), PSYM=psym, _EXTRA=extra
       ENDFOR

   ENDIF ELSE BEGIN

       IF N_ELEMENTS(psym) EQ 0 THEN psym = 7

       EnhancedPlot, xVal(indRetain), yVal(indRetain), PSYM=psym, XERR=xErr(indRetain), YERR=yErr(indRetain), XSTYLE=1, YSTYLE=1, OPLOT=oplot, _EXTRA=extra

   ENDELSE

   xAvg = xVal(indRetain)
   yAvg = yVal(indRetain)

END
