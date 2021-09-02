; Calculates the value of the data set at the pth percentile

FUNCTION Percentile, data, p, ind
   ; p can be an array of percentiles.
   ; ind is a returned array of the corresponding indices
   indSorted = SORT(data)
   
   element = LONG(N_ELEMENTS(data) * FLOAT(p)/100)

   indEnd = WHERE(element GE N_ELEMENTS(data))
   IF indEnd(0) GE 0 THEN element(indEnd) = N_ELEMENTS(data)-1
   indStart = WHERE(element LT 0)
   IF indStart(0) GE 0 THEN element(indStart) = 0

   ind = indSorted(element)

   RETURN, data(ind)
   
END
