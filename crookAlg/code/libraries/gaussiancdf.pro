FUNCTION GaussianCDF, x
   RETURN, 0.5 * (1 + ERF(x/SQRT(2)) )
END
