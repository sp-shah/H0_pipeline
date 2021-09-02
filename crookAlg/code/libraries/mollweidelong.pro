; Draw Line of Longitude on Mollweide Map

PRO MollweideLong, longitude,lambda0, HOURS=hours, TEXTCOL=textcol, $
                   CENTERB=CenterB, CENTERL=CenterL, $
                   LONGLABELLAT=LongLabelLat,_EXTRA = extra
   ; Construct line at const Longitude
   ; Use /HOURS to write 12^h rather than 180, etc.
   ; LongLabelLat is the latitude to place the longitude labels at.
   ; Default = 0 (degrees)

   IF N_ELEMENTS(LongLabelLat) EQ 0 THEN LongLabelLat = 0

   NPoints = 1000

   phi  = (180*(1+FLOAT(FINDGEN(NPoints))) / (NPoints+1)) - 90

   lambda     = FLTARR(NPoints)
   lambda(*)  = longitude

   coords = Mollweide(phi,lambda,lambda0, CENTERB=CenterB, CENTERL=CenterL)

   TextCoord = Mollweide(LongLabelLat, longitude+0.00001, lambda0, CENTERB=CenterB, CENTERL=CenterL)

   IF KEYWORD_SET(hours) THEN BEGIN
       TextDisplay = STRTRIM(STRING(NumInInterval(ROUND(longitude/15),0,24)),2) + "!Uh"
   ENDIF ELSE BEGIN
       TextDisplay = STRTRIM(STRING(ROUND(longitude)),2) + "!U!M%!X"
   ENDELSE

   OPlotLine, coords(*,0),coords(*,1),JumpLimit=0.1,LINESTYLE=2,_EXTRA = extra
   XYOUTS, TextCoord(0), TextCoord(1)+0.02, TextDisplay, ALIGN=0.5, COLOR=textcol

END
