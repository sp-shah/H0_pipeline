FUNCTION ThoroughWhere, list, comp
   ; Sometimes WHERE fails for no apparent reason.
   ; In this case, use this routine.

   Result = INTARR(N_ELEMENTS(list))
   Count = 0

   FOR i = 0, N_ELEMENTS(list)-1 DO BEGIN
       IF list(i) EQ comp THEN BEGIN
           Result(Count) = i
           Count++
       ENDIF
   ENDFOR

   IF Count EQ 0 THEN BEGIN
       Result(0) = -1
       Count++
   ENDIF

   Result = Result(0:Count-1)

   RETURN, Result
END
