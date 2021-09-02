PRO SavePlot
   ; Stores the Plot Variables, so that it can be returned to later
   ; Using RestorePlot

   COMMON StorePlotVariables, Plot0, x0, y0, WindowIndex

   WindowIndex = !D.WINDOW
   Plot0 = !P
   x0 = !x
   y0 = !y

END
