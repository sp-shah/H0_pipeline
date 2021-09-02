; Returns a 2-D array containing the data in each bin
; Array(Bin, *) contains the data
; NumInBin(Bin) contains the number of data points in each bin
; Will be equal to the number requested in all but the last bin

FUNCTION BinEqualNum, Data, BinSize, NUMINBIN=NumInBin, BINWIDTH=BinWidth, $
                      LARGELASTBIN=LargeLastBin

   IF KEYWORD_SET(LargeLastBin) THEN $
     NumBins = FLOOR(FLOAT(N_ELEMENTS(Data)) / BinSize) ELSE $
     NumBins = CEIL(FLOAT(N_ELEMENTS(Data)) / BinSize)
     

   MaxBinSize = MAX([BinSize, N_ELEMENTS(Data) - BinSize*(NumBins-1)])
   Result = LONARR(NumBins, MaxBinSize)
   NumInBin = INTARR(NumBins)
   BinWidth = FLTARR(NumBins)

   indSorted = SORT(Data)
   
   FOR i = 0, NumBins - 1 DO BEGIN
       BinStart = i*BinSize
       
       IF i LT NumBins-1 THEN BEGIN
           BinEnd = (i+1)*BinSize - 1
           BinWidth(i) = Data(indSorted(BinEnd+1))-Data(indSorted(BinStart))
       ENDIF ELSE BEGIN
           BinEnd = N_ELEMENTS(Data)-1
           BinWidth(i) = Data(indSorted(BinEnd))-Data(indSorted(BinStart))
       ENDELSE

       NumInBin(i) = BinEnd-BinStart + 1
       Result(i, 0:(BinEnd-BinStart)) = indSorted(BinStart:BinEnd)
       
   ENDFOR

   RETURN, Result

END
