PRO ContoursFromPoints, x, y, NUMXBINS=NumXBins,NUMYBINS=NumYBins, _EXTRA=extra
   ; Create Grid:

   zBin = CountsInCells(x, y, NUMXBINS=NumXBins,NUMYBINS=NumYBins, XBIN=xBin,YBIN=yBin)

   CONTOUR, zBin, xBin, yBin, LEVELS=[1,5], _EXTRA=extra

END
