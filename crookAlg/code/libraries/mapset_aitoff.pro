PRO MapSet_Aitoff, P0lat, P0lon, theta, NOGRID=NoGrid, COL=colAxes, BORDER=border, _EXTRA=extra
   ; Set up Aitoff Grid for Galactic Coords

   IF N_ELEMENTS(P0lat) EQ 0 THEN P0lat = 0
   IF N_ELEMENTS(P0lon) EQ 0 THEN P0lon = 0
   IF N_ELEMENTS(theta) EQ 0 THEN theta = 0
   IF NOT KEYWORD_SET(border) THEN border=0
   

   MAP_SET, P0lat, P0lon, theta, /AITOFF, REVERSE=1, COL=colAxes, NOBORDER=(KEYWORD_SET(border) EQ 0), _EXTRA=extra
   IF NOT KEYWORD_SET(NoGrid) THEN AitoffGrid, COL=colAxes
END
