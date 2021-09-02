PRO BinEqualNumber, InputArray, NumberPerBin, BinMean, BinWidth, BinStdDev, NumInBin, REVERSE=reverse, BINSTART=BinStart, BINEND=BinEnd, SMALLLASTBIN=SmallLastBin, WEIGHT=weight

   ; If /SMALLLASTBIN set then final bin will contain <= NumberPerBin

   ; Returns 4 arrays:
   ; the Mean value of items in the bin
   ; the bin width
   ; the standard deviation of items in the bin
   ; the actual number in each bin

   ; If /REVERSE is set then the binning starts at the max value

   ; weight is an optional array, that will affect the values returned
   ; if not present, weight(*) = 1

   SortOrder = SORT(InputArray)
   
   IF KEYWORD_SET(reverse) THEN SortOrder = REVERSE(SortOrder)

   IF N_ELEMENTS(weight) EQ 0 THEN BEGIN
       weight = FLTARR(N_ELEMENTS(InputArray))
       weight(*) = 1.
   ENDIF

   SortedArray = InputArray(SortOrder)
   WeightArray = weight(SortOrder)

   iStart = LONG(0)
   iEnd = LONG(0)
   count = LONG(0)

   IF KEYWORD_SET(SmallLastBin) THEN BEGIN
       NumBins = CEIL(FLOAT(N_ELEMENTS(InputArray)) / NumberPerBin)
   ENDIF ELSE BEGIN
       NumBins = MAX([FLOOR(FLOAT(N_ELEMENTS(InputArray)) / NumberPerBin),1])
   ENDELSE

   BinMean = FLTARR(NumBins)
   BinStdDev = DBLARR(NumBins)
   BinWidth = DBLARR(NumBins)
   BinStart = DBLARR(NumBins)
   BinEnd = DBLARR(NumBins)
   NumInBin = DBLARR(NumBins)

   FOR i = 0L, NumBins-1 DO BEGIN
       iEnd = iStart+NumberPerBin-1
       IF i EQ NumBins-1 THEN iEnd = N_ELEMENTS(InputArray) - 1

       BinMean(i) = MEAN(SortedArray(iStart:iEnd))
       BinStdDev(i) = STDDEV(SortedArray(iStart:iEnd))
       IF i GT 0 THEN $
         BinStart(i) = (SortedArray(iStart) + SortedArray(iStart-1)) / 2 $
       ELSE BinStart(i) = SortedArray(0)
       
       NumInBin(i) = TOTAL(WeightArray(iStart:iEnd))

       IF i LT NumBins-1 THEN $
         BinEnd(i) = (SortedArray(iEnd+1) + SortedArray(iEnd)) / 2 $
       ELSE BinEnd(i) = SortedArray(iEnd)

       BinWidth(i) = ABS(BinEnd(i) - BinStart(i))

       iStart = iEnd+1
   ENDFOR

END
