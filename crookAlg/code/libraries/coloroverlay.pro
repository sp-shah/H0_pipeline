; OverPlot Points on graph using array of colors specified

PRO ColorOverlay, x, y, colors, _EXTRA = extra
   
   i = LONG(0)
   WHILE i LT N_ELEMENTS(x) DO BEGIN
       OPLOT, [x(i)],[y(i)], COLOR=colors(i), _EXTRA = extra 
       i++
   ENDWHILE

END
