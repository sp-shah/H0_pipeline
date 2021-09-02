; Create a Cumulative Density Function from the given data.
; Returns abscissa values and Absolute Numbers

PRO CalcCDF, data, abscissa, N
   mindata = MIN(data)
   abscissa = [mindata, data(SORT(data))]
   N = FLOAT(FINDGEN(N_ELEMENTS(data)+1)) / N_ELEMENTS(data)
END
