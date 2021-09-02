PRO RestorePlot
   ; Restores the Plot Variables saved using SavePlot

   COMMON StorePlotVariables, Plot0, x0, y0, WindowIndex

   WSET, WindowIndex
   !P = Plot0
   !x = x0
   !y = y0

END
