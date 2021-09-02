FUNCTION SparseArray, InputArray,n
  ; Extracts evenly spaced n elements from array - returns pointer to them

  stepsize = FLOAT(N_ELEMENTS(InputArray))/FLOAT(n)
  
  arrayindex = LONG(stepsize*FLOAT(FINDGEN(n)))

  RETURN, arrayindex

END
