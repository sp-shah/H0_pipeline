
PRO AitoffGrid, COL=colAxes, Nlat=Nlat, Nlon=Nlon, LATLAB=latlab, LONLAB=lonlab
   ; Draw a grid and label on an (Airoff) Map Projection in 
   ; Galactic Coords

   IF N_ELEMENTS(Nlat) EQ 0 THEN Nlat=7
   IF N_ELEMENTS(Nlon) EQ 0 THEN Nlon=9

   IF N_ELEMENTS(latlab) EQ 0 THEN latlab=0
   IF N_ELEMENTS(lonlab) EQ 0 THEN lonlab=15

   LatLines = FIX(180*FINDGEN(Nlat)/(Nlat-1) - 90)
   LonLines = FIX(360 * FINDGEN(Nlon)/(Nlon-1))

   LonLabels = STRTRIM(LonLines,2)
   LonLabels([0,Nlon-1]) = ""
   LatLabels = STRTRIM(LatLines,2)
   LatLabels([0,Nlat-1]) = ""

   MAP_GRID, /LABEL, LATLAB=latlab, LONLAB=lonlab, LONS=LonLines, LONNAMES=LonLabels, /HORIZON, LATS=LatLines, LATNAMES=LatLabels, COL=colAxes

END
