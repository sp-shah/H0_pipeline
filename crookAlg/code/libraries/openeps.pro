; Saves to an EPS file - requires CloseEPS to be run afterwards
; AspectRatio is xsize/ysize for plot
; PageFrac = Fraction of a page that the figure is expected to take up
; (1 for whole page, 0.5 for column-width assuming 2 columns per page)
; - Default is 0.5


PRO OpenEPS, FileName, COLOR=color, CT=ColorTable, XSIZE=xsize, YSIZE=ysize, ASPECTRATIO=aspectratio, PAGEFRAC=PageFrac

   SavePlot

   IF N_ELEMENTS(PageFrac) EQ 0 THEN PageFrac = 0.5

   PageFrac = FLOAT(PageFrac)  

   !P.CHARSIZE = 1./(1 - 2*(1-PageFrac)/3)
   !P.THICK = 2./(1 - 2*(1-PageFrac)/3)
   
   defsize = 6.0 ; For thesis figures
;   defsize = 4.0 ; For 2-column journal publications


   IF KEYWORD_SET(aspectratio) THEN BEGIN
       IF aspectratio LT 1 THEN BEGIN
           ysize = defsize
           xsize = ysize*aspectratio
       ENDIF ELSE BEGIN
           xsize = defsize
           ysize = xsize/aspectratio
       ENDELSE
   ENDIF

   IF NOT KEYWORD_SET(xsize) THEN xsize = defsize
   IF NOT KEYWORD_SET(ysize) THEN ysize = defsize


   SET_PLOT, 'ps'
   IF KEYWORD_SET(color) AND NOT KEYWORD_SET(ColorTable) THEN ColorTable = 4
   IF KEYWORD_SET(ColorTable) THEN BEGIN
       LOADCT, ColorTable
       color = 1
   ENDIF
   
   DEVICE, FILENAME=FileName, BITS_PER_PIXEL=8, XSIZE=xsize, YSIZE=ysize, /INCHES, COLOR=color, /ENCAPSULATED

END
