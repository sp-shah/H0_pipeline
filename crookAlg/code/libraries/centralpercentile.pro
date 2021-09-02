FUNCTION CentralPercentile, data, Percentile
   ; Return the indices corresponding to the central Percentile%
   ; of the data

   SortedData = SORT(data)
   N = N_ELEMENTS(data)

   StartInd = FLOOR(FLOAT(N)*(1 - FLOAT(Percentile)/100)/2)
   EndInd = FLOOR(FLOAT(N)*(1 + FLOAT(Percentile)/100)/2)

   IF EndInd GE N-1 THEN EndInd = N-1

   RETURN, SortedData(StartInd:EndInd)

END
