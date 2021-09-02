; CapArray

; Returns the array elements, but replaces values below MAX with max
; and below MIN with min

FUNCTION CapArray, Elements, MAX=max, MIN=min
   Result = Elements

   IF N_ELEMENTS(max) GT 0 THEN BEGIN
       OverMax = WHERE(Elements GT max)
       IF OverMax(0) GE 0 THEN Result(OverMax) = max
   ENDIF

   IF N_ELEMENTS(min) GT 0 THEN BEGIN
       UnderMin = WHERE(Elements LT min)
       IF UnderMin(0) GE 0 THEN Result(UnderMin) = min
   ENDIF

   RETURN, Result

END
