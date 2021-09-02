; The opposite of FLOATORSET
; Returns the string of the number, but if it is xCheck, then set to strSet

FUNCTION StringOrSet, x, xCheck, strSet, FORMAT=strformat
   indString = WHERE(x NE xCheck, COMPLEMENT=indNotString)
   
   ReturnStr = STRARR(N_ELEMENTS(x))
   IF indString(0) GE 0 THEN BEGIN
       ReturnStr(indString) = STRING(x(indString), FORMAT=strformat)
   ENDIF
   IF indNotString(0) GE 0 THEN BEGIN
       ReturnStr(indNotString) = strSet
   ENDIF
   
   RETURN, ReturnStr

END
