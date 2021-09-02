; x is an array with values 0->1
; Return RGB color for each value such that
; 0 --> Blue, 0.5 --> Green, 1 --> Red

FUNCTION RedGreenBlueScale, x
   RETURN, RGB(255*(1-x), 255*(1-ABS(x - 0.5)), 255*x)
END
