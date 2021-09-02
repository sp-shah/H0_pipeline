FUNCTION FloatOrSet, x, xDefault
   ; Given strings x - will convert to float.
   ; If string is "" then x = xDefault (0 by default)

   IF N_ELEMENTS(xDefault) EQ 0 THEN xDefault = 0

   ReturnArray = FLTARR(N_ELEMENTS(x))
   indSet = WHERE(STRTRIM(x,2) NE "", COMPLEMENT=indNotSet)

   IF indSet(0) GE 0 THEN ReturnArray(indSet) = x(indSet)
   IF indNotSet(0) GE 0 THEN ReturnArray(indNotSet) = xDefault

   RETURN, ReturnArray

END
