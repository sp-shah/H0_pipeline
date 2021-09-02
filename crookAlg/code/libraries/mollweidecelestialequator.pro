; Draw Celestial Equator on Mollweide Projection in Galactic Coordinates

PRO MollweideCelestialEquator, lambda0, _EXTRA = extra

   NPoints = 1000

   RA  = (24*FLOAT(FINDGEN(NPoints)+1) / (NPoints+1))

   Dec     = FLTARR(NPoints)
   Dec(*)  = 0.

   ConvertEqToGal, RA, Dec, b, l
   
   coords = Mollweide(b,l,lambda0)

   JumpAmount = 0.1

   PlotStart = 0

   FOR i = 0, N_ELEMENTS(coords(*,0))-2 DO BEGIN
       IF ABS(coords(i,0) - coords(i+1,0)) GT JumpAmount THEN BEGIN
           OPLOT, coords(PlotStart:i,0),coords(PlotStart:i,1),_EXTRA = extra
           PlotStart = i+1
       ENDIF
   ENDFOR
   
   OPLOT, coords(PlotStart:NPoints-1,0),coords(PlotStart:NPoints-1,1),_EXTRA = extra

END
