; EPS Filename to Save it

PRO MakeColorBar, ValueList, ColorList, FILENAME=FileName, CT=ColorTable
  
   yMax = 10

   IF KEYWORD_SET(FileName) THEN BEGIN
       OpenEPS, FileName, CT=ColorTable, XSIZE=12, YSIZE=0.8
   ENDIF

   
   PLOT, [0],[0], XRANGE=[MIN(ValueList), MAX(ValueList)], YRANGE=[0,yMax], YTICKS=1, XSTYLE=1, YSTYLE=1, YTICKFORMAT='(A1)', POSITION=[0.05,0.4,0.95,0.95]

   ; First Rectangle - 0.5 size
   FilledRect, ValueList(0),0, FLOAT(ValueList(1)-ValueList(0))/2, yMax, COL=ColorList(0)

   FOR i = 1, N_ELEMENTS(ColorList)-2 DO BEGIN
       FilledRect, FLOAT(ValueList(i)+ValueList(i-1))/2, 0, FLOAT(ValueList(i+1)-ValueList(i-1))/2, yMax, COL=ColorList(i)
   ENDFOR
      
   ; Last Rectangle - 0.5 size
   FilledRect, FLOAT(ValueList(i)+ValueList(i-1))/2,0,FLOAT(ValueList(i)-ValueList(i-1))/2, yMax, COL=ColorList(i)

   AXIS, YAXIS=0, YTICKFORMAT='(A1)', YTICKS=1, TICKLEN=0
   AXIS, YAXIS=1, YTICKFORMAT='(A1)', YTICKS=1, TICKLEN=0
   AXIS, XAXIS=1, XTICKFORMAT='(A1)', XTICKS=1
   AXIS, XAXIS=0, XTICKFORMAT='(A1)', XTICKS=1

   IF KEYWORD_SET(FileName) THEN BEGIN
       CloseEPS
   ENDIF


END


PRO TestColorBar
   X = FINDGEN(100)
   Y = NumInRange(100,0,255)

   MakeColorBar, X, Y

END
