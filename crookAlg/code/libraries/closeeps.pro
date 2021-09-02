; Use in conjunction with openEPS to save EPS file
PRO CloseEPS
   DEVICE, /CLOSE
   SET_PLOT, 'x'
   
   RestorePlot

END
