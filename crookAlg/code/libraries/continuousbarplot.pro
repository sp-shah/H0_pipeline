; ***************************************************
;  ContinuousBarPlot
;    Aidan Crook
;    Last Modified 09/27/2007
;
;  Creates a box-like bar plot with no dividing lines
; ***************************************************

PRO ContinuousBarPlot, data, BinSize, EPSFILE=epsfile, DATASETSIZE=DataSetSize, LABEL=Label, FRACTION=Fraction, YPLUS20=yplus20, OPLOT=oplot, LINETHICK=linethick, LINESTYLE=linestyle, STATS=stats, NUMBYAREA=NumByArea, NORMALIZED=normalized, YSCALE=yScale, COLOR=color, _EXTRA=extra
  
   ; BinSize is width of each bin (if not present, 25 divisions assumed)
   ; Note: DataSetSize must be set if you want to plot multiple graphs 
   ;  (It is equal to the largest number of elements in a dataset that you want plotted)
   ; /YPLUS20 makes Y-axis 20% larger than it otherwise would be
   ;  (to better fit the legend)
   ; If /FRACTION is set then the values are fractions of the sample size
   ; If /OPLOT set then overplot the graph on current figure
   ; LABEL=["name of data1", "name of data2"], etc. for Legend
   ; LINETHICK=[1,2] for different thicknesses when plotting multiple datasets
   ; /NUMBYAREA makes the area represent
   ;   the number of points rather than the height
   ; /NORMALIZED sets both /FRACTION and /NUMBYAREA
   ; YSCALE is multiplied by ALL y values. Default = 1

   IF MAX(data) GT 2e9 OR MIN(data) LT -2e9 THEN BEGIN
       PRINT, "Numbers too big"
       RETURN                   ; Numbers too big (!)
   ENDIF

   IF KEYWORD_SET(normalized) THEN BEGIN
       numbyarea = 1
       fraction = 1
   ENDIF

   IF N_ELEMENTS(BinSize) EQ 0 THEN BinSize = FLOAT(MAX(data)-MIN(data))/ 24.9
   IF BinSize EQ 0. THEN BinSize = 1.

   IF NOT KEYWORD_SET(DataSetSize) THEN DataSetSize = N_ELEMENTS(data(*, 0))

   IF N_ELEMENTS(yScale) EQ 0 THEN yScale = 1.

   YEnlarge = 1.25  ; This should really be 1.20 for 20% bigger

   NumDataSets = N_ELEMENTS(data(0, *))

   MinVal = MAX(data)

   MaxVal = (CEIL(FLOAT(MAX(data)) / BinSize)) * BinSize

   IF MAX(data) GE MaxVal THEN MaxVal = MaxVal + BinSize

   FOR i = 0, NumDataSets-1 DO BEGIN
       curMinVal = (FLOOR(FLOAT(MIN(data(0:DataSetSize(i)-1, i))) / BinSize)) * BinSize
       IF curMinVal LT MinVal THEN MinVal = curMinVal
   ENDFOR

   NumBins = CEIL((MaxVal - MinVal) / BinSize)

   x = FLOAT(FINDGEN(NumBins+1))*BinSize + MinVal
   
   y = FLTARR(NumBins+1, NumDataSets)

   FOR i = 0, NumDataSets-1 DO BEGIN
       CurrentDataSet = DOUBLE(data(0:DataSetSize(i)-1, i))
       
       HistValues = HISTOGRAM(CurrentDataSet, BINSIZE=BinSize, MIN=MinVal)
       IF KEYWORD_SET(Fraction) THEN ScaleFactor = TOTAL(HistValues) ELSE $
         ScaleFactor = 1

       y(0:N_ELEMENTS(HistValues),i) = yScale * [HistValues, 0] / ScaleFactor

       IF KEYWORD_SET(NumByArea) THEN y = y / BinSize
 
       IF KEYWORD_SET(stats) THEN BEGIN
           PRINT, "Mean: ", MEAN(CurrentDataSet), $
             " : Median: ", MEDIAN(CurrentDataSet)
           PRINT, " : 25,75 %-iles: ", CommaSepArray(Percentile(CurrentDataSet, [25,75])), $
             " : StdDev: ", STDDEV(CurrentDataSet)
           
       ENDIF

   ENDFOR

   MaxPlotY = MAX(y)
   IF KEYWORD_SET(yplus20) THEN MaxPlotY = MaxPlotY * YEnlarge

   IF NOT KEYWORD_SET(oplot) THEN BEGIN
       PLOT, [x(0)], [y(0,0)], /NODATA, XRANGE=[MinVal, MaxVal],  $
         YRANGE=[0, MaxPlotY], _EXTRA = extra
   ENDIF
   
   FOR i = 0, NumDataSets-1 DO BEGIN
       BoxGraph, x, y(*, i), xPlot, yPlot
       IF N_ELEMENTS(linestyle) GT i THEN linestyle1 = linestyle(i) ELSE linestyle1=i*2
       OPLOT, xplot, yplot, LINESTYLE=linestyle1, THICK=linethick, COLOR=color
   ENDFOR

   IF KEYWORD_SET(Label) THEN BEGIN
       LEGEND, Label, /TOP, /RIGHT, LINESTYLE=FINDGEN(NumDataSets)*2
   ENDIF

   IF N_ELEMENTS(epsfile) GT 0 THEN BEGIN
       OpenEPS, epsfile

       PLOT, [x(0)], [y(0,0)], /NODATA, XRANGE=[MinVal, MaxVal],  $
         YRANGE=[0, MaxPlotY], _EXTRA = extra
       
       FOR i = 0, NumDataSets-1 DO BEGIN
           BoxGraph, x, y(*, i), xPlot, yPlot
           IF N_ELEMENTS(linestyle) GT i THEN linestyle1 = linestyle(i) ELSE linestyle1=i*2
           
           OPLOT, xplot, yplot, LINESTYLE=linestyle1, THICK=linethick ;, COLOR=color
       ENDFOR
       
       IF KEYWORD_SET(Label) THEN BEGIN
           LEGEND, Label, /TOP, /RIGHT, LINESTYLE=FINDGEN(NumDataSets)*2
       ENDIF

       CloseEPS       
   ENDIF

END
