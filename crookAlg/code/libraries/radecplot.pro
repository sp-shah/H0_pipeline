

FUNCTION RADecPlot, RA, Dec, NUMDIVISIONS=NumDivisions, _EXTRA=extra

   ; Creates and lables an empty set of axes that is isotropic in RA & Dec
   ; e.g. for finding charts, etc.

   ; Returns the value of the minimum x-axis value on the plot  
   ; To plot data, use the NumInInterval(RA,MinRA, MinRA+24) function


   IF N_ELEMENTS(NumDivisions) EQ 0 THEN NumDivisions = 5

   RADivisionSizes = [5./60, 10./60, 15./60, 30./60, 1., 2., 3., 4., 5.]
   DecDivisionSizes = [15./60, 30./60, 1., 2., 3., 4., 5., 10., 15., 20., 30., 45.]

   FindCenter, RA, Dec, CenterRA, CenterDec

   RAShift = ROUND(CenterRA)

   RARelToCenter = NumInInterval(RA - RAShift, -12, 12) + RAShift



   ; Determine the plot size
   RARange = MAX(RARelToCenter) - MIN(RARelToCenter)
   DecRange = MAX(Dec) - MIN(Dec)

   RADivisionSize = RoundToList(RARange/NumDivisions, RADivisionSizes)
   TrueRAMin = RoundToMultiple(MIN(RARelToCenter), RADivisionSize, /FLOOR)
   TrueRAMax = RoundToMultiple(MAX(RARelToCenter), RADivisionSize, /CEIL)

   DecDivisionSize = RoundToList(DecRange/NumDivisions, DecDivisionSizes)
   TrueDecMin = RoundToMultiple(MIN(Dec), DecDivisionSize, /FLOOR)
   TrueDecMax = RoundToMultiple(MAX(Dec), DecDivisionSize, /CEIL)

   ; Force to be roughly Isotropic on square plot
   IF (TrueDecMax - TrueDecMin) GT (TrueRAMax - TrueRAMin) * 15 THEN BEGIN
       ; Need to enlarge RA axis
       RAMax = (Min(RARelToCenter) + Max(RARelToCenter))/2 + (TrueDecMax - TrueDecMin)/(2*15)
       RAMin = (Min(RARelToCenter) + Max(RARelToCenter))/2 - (TrueDecMax - TrueDecMin)/(2*15)

       RADivisionSize = RoundToList((RAMax - RAMin)/NumDivisions, RADivisionSizes)
       TrueRAMin = RoundToMultiple(RAMin, RADivisionSize, /FLOOR)
       TrueRAMax = RoundToMultiple(RAMax, RADivisionSize, /CEIL)
   ENDIF ELSE BEGIN
       ; Need to enlarge Dec Axis
       DecMax = (Min(Dec) + Max(Dec))/2 + 15*(TrueRAMax - TrueRAMin)/2
       DecMin = (Min(Dec) + Max(Dec))/2 - 15*(TrueRAMax - TrueRAMin)/2

       DecDivisionSize = RoundToList((DecMax - DecMin)/NumDivisions, DecDivisionSizes)
       TrueDecMin = RoundToMultiple(DecMin, DecDivisionSize, /FLOOR)
       TrueDecMax = RoundToMultiple(DecMax, DecDivisionSize, /CEIL)

   ENDELSE


   ; Don't plot unphysical declinations
   Above90 = TrueDecMax - 90
   IF Above90 GT 0 THEN BEGIN
       TrueDecMax = 90
       TrueDecMin = TrueDecMin - Above90
   ENDIF

   Below90 = -90 - TrueDecMin
   If Below90 GT 0 THEN BEGIN
       TrueDecMin = -90
       TrueDecMax = TrueDecMax + Below90
       IF TrueDecMax GT 90 THEN TrueDecMax = 90
   ENDIF

   RATicks  = (TrueRAMax-TrueRAMin)   / RADivisionSize
   DecTicks = (TrueDecMax-TrueDecMin) / DecDivisionSize

   RATickLabels = REVERSE(NumInInterval(FINDGEN(RATicks + 1) * RADivisionSize + TrueRAMin,0,24))

   strRATickLabels = STRLEFT(StandardRA(RATickLabels, /GRAPHIC), 14)

   IF RADivisionSize GE 1 THEN strRATickLabels = strLeft(strRATickLabels,7)

   strRATickLabelsIDL = TeXtoIDL(strRATickLabels)

   PLOT, [0],[0], /NODATA, XSTYLE=1, YSTYLE=1, XRANGE=[TrueRAMax, TrueRAMin], $
     YRANGE=[TrueDecMin, TrueDecMax], XTICKS=RATicks, YTICKS=DecTicks, $
     XTICKNAME=strRATickLabelsIDL, XTITLE = "Right Ascension", $
     YTITLE = "Declination (degrees)", _EXTRA=extra

   RETURN, TrueRAMin

END
