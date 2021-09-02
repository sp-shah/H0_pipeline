; Draw Line of Latitude on Mollweide Map

PRO MollweideLatText, Latitude, CENTERB=CenterB, CENTERL=CenterL, $
                      TEXTCOL=textcol, LATLABELLONG=LatLabelLong

   IF N_ELEMENTS(LatLabelLong) EQ 0 THEN BEGIN
       
       TextCoordR = Mollweide(latitude, 180, 0, CENTERB=CenterB, CENTERL=CenterL)
       TextCoordL = Mollweide(latitude, 179.99, 0, CENTERB=CenterB, CENTERL=CenterL)
       XYOUTS, TextCoordR(0), TextCoordR(1)-0.04, "  " + STRTRIM(STRING(ROUND(latitude)),2) + "!U!M%!X!N", ALIGN=0.0, COLOR=textcol
       XYOUTS, TextCoordL(0), TextCoordL(1)-0.04, STRTRIM(STRING(ROUND(latitude)),2) + "!U!M%!X!N  ", ALIGN=1.0, COLOR=textcol
   ENDIF ELSE BEGIN
       TextCoordC = Mollweide(latitude, LatLabelLong, 0, CENTERB=CenterB, CENTERL=CenterL)
       XYOUTS, TextCoordC(0), TextCoordC(1), STRTRIM(STRING(ROUND(latitude)),2) + "!U!M%!X!N  ", ALIGN=0.5, COLOR=textcol
   ENDELSE



END

PRO MollweideLat, latitude, CENTERB=CenterB, CENTERL=CenterL, $
                  TEXTCOL=textcol, LATLABELLONG=LatLabelLong, _EXTRA = extra

   ; Construct line at const Latitude

   NPoints = 1000

   lambda  = (360*FLOAT(FINDGEN(NPoints)) / NPoints) - 180

   phi     = FLTARR(NPoints)
   phi(*)  = latitude

   coords = Mollweide(phi,lambda,0, CENTERB=CenterB, CENTERL=CenterL)

;   print, coords(0,0:1)
;   print, coords(1,0:1)

   OPlotLine, coords(*,0),coords(*,1),LINESTYLE=2,JumpLimit=0.1,_EXTRA = extra

   MollweideLatText, Latitude, CENTERB=CenterB, CENTERL=CenterL, $
     TEXTCOL=textcol, LATLABELLONG=LatLabelLong

END
