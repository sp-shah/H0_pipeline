FUNCTION RMS, x
   ; Computes the RMS Value of the array x
   RETURN, SQRT(MEAN(x^2))
END
