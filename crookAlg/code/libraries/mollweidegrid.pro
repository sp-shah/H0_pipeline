; Overlay Grid on Mollweide Map

PRO MollweideGrid, lambda0, TEXTCOL=textcol, HOURS=hours, $
                   LONGLABELLAT=LongLabelLat, LATLABELLONG=LatLabelLong, $
                   CENTERB=CenterB, CENTERL=CenterL, $
                   NUMLATLABELS=Nlat, NUMLONGLABELS=Nlong, $
                   _EXTRA = extra

   IF N_ELEMENTS(lambda0) EQ 0 THEN lambda0 = 0.

   IF N_ELEMENTS(Nlat) EQ 0 THEN Nlat = 5
   IF N_ELEMENTS(Nlong) EQ 0 THEN Nlong = 6

   llat = (180*FLOAT(FINDGEN(Nlat)+1) / (Nlat+1)) - 90
   llong = 360*FLOAT(FINDGEN(Nlong)) / Nlong

   l180 = WHERE(llong EQ 180-lambda0)
   IF l180(0) GE 0 THEN llong = [llong, NumInInterval(DOUBLE(179.999)-lambda0,0,360)]

   FOR i = 0, Nlat-1 DO BEGIN
       MollweideLat, llat(i), CENTERB=CenterB, CENTERL=CenterL, TEXTCOL=textcol, $
         LATLABELLONG=LatLabelLong, _EXTRA = extra
   ENDFOR

   ; Write +/- 90 on map:
   TextCoordTop = Mollweide(89.999, 0, 0, CENTERB=CenterB, CENTERL=CenterL)
   TextCoordBottom = Mollweide(-89.999, 0, 0, CENTERB=CenterB, CENTERL=CenterL)

   XYOUTS, TextCoordTop(0), TextCoordTop(1)+0.07, "90!U!M%!X!N", ALIGN=0.5, COLOR=textcol
   XYOUTS, TextCoordBottom(0), TextCoordBottom(1)-0.15, "-90!U!M%!X!N", ALIGN=0.5, COLOR=textcol

   FOR i = 0, N_ELEMENTS(llong)-1 DO BEGIN
       MollweideLong, llong(i), lambda0, HOURS=hours, TEXTCOL=textcol, $ 
         LONGLABELLAT=LongLabelLat, CENTERB=CenterB, CENTERL=CenterL, _EXTRA = extra
   ENDFOR

END
