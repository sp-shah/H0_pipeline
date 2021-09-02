; Given input array x - output a corresponding value between 0 and 1
;                       for each x value, such that the outputted
;                       values are uniformly distributed

FUNCTION ScaleToUniform, x
   indSorted = SORT(x)
   RetVal = FINDGEN(N_ELEMENTS(x)) / (N_ELEMENTS(x)-1)
   
   RetSorted = FLTARR(N_ELEMENTS(x))
   RetSorted(indSorted) = RetVal

   RETURN, RetSorted

END
