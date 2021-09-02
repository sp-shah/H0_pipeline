FUNCTION CountsInCells, x, y, NUMXBINS=NumXBins,NUMYBINS=NumYBins, $
                        XBIN=xBin,YBIN=yBin
   ; Computes the number per cell dividing the data in to a
   ; rectangular grid.

   IF NOT KEYWORD_SET(NumXBins) THEN NumXBins = 20
   IF NOT KEYWORD_SET(NumYBins) THEN NumYBins = 20

   XRange = MAX(x)-MIN(x)
   XBinSize = XRange / NumXBins
   XBinEdges = MIN(x) + FINDGEN(NumXBins+1) * XBinSize

   YRange = MAX(y)-MIN(y)
   YBinSize = YRange / NumYBins
   YBinEdges = MIN(y) + FINDGEN(NumYBins+1) * YBinSize
   
   xBin = FLTARR(NumXBins, NumYBins)
   yBin = FLTARR(NumXBins, NumYBins)
   zBin = INTARR(NumXBins, NumYBins)
   
   FOR i = 0, NumXBins-1 DO BEGIN

       IF i LT NumXBins-1 THEN $
         indInXRange = WHERE(x GE XBinEdges(i) AND x LT XBinEdges(i+1)) $
       ELSE indInXRange = WHERE(x GE XBinEdges(i) AND x LE XBinEdges(i+1))

       FOR j = 0, NumYBins-1 DO BEGIN
           xBin(i,j) = XBinEdges(i) + XBinSize/2
           yBin(i,j) = YBinEdges(j) + YBinSize/2

           IF indInXRange(0) GE 0 THEN BEGIN
               ; Check for y-values
               IF j LT NumYBins THEN $
                 zBin(i,j) = WhereSize(WHERE(y(indInXRange) GE YBinEdges(j) AND $
                                             y(indInXRange) LT YBinEdges(j+1))) $
               ELSE zBin(i,j) = WhereSize(WHERE(y(indInXRange) GE YBinEdges(j) AND $
                                                 y(indInXRange) LE YBinEdges(j+1)))
           ENDIF
       ENDFOR   
   ENDFOR

   RETURN, zBin
   
END
