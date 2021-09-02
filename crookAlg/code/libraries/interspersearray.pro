FUNCTION IntersperseArray, InputArray
  ; Takes array & places 2nd hald of list intermittently
  ; through 1st half - e.g. 1 2 3 4 --> 1 3 2 4

  NewArray=InputArray

  arraysize=N_ELEMENTS(InputArray)
  halfstart=FIX(arraysize/2)
  ind = FINDGEN(halfstart)

  NewArray(ind*2) = InputArray(ind)
  NewArray(ind*2+1) = InputArray(ind+halfstart)

  RETURN, NewArray

END
