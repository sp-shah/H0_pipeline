PRO CalcNumberDensity, Dist, NumPerBin, x, y, YERR=yErr, XERR=xErr, SKYFRAC=skyfrac, WEIGHT=weight
     
   IF N_ELEMENTS(SkyFrac) EQ 0 THEN SkyFrac = 1.
   BinEqualNumber, Dist, NumPerBin, BinMean, BinWidth, BinStdDev, NumInBin, BINSTART=BinStart, BINEND=BinEnd, WEIGHT=weight
   BinVolume = (4.*!PI/3) * (BinEnd^3 - BinStart^3) * SkyFrac
   NumberDensity = FLOAT(NumInBin) / BinVolume

   x = BinMean
   y = NumberDensity
   yErr = SQRT(NumInBin) / BinVolume
   xErr = BinStdDev

END
