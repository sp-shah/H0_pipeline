; Takes an array x
; Returns an array of numbers between 0 and 1 where 0 corresponds to
; the element MIN(x) and 1 corresponds to MAX(x).
; Scaling is linear by default

; Override Min, Max by providing specified values
; If /CAP set, then set anything lower/higher than provided Min/Max to 0/1

FUNCTION ReScaleValue, x, MIN=minx, MAX=maxx, CAP=cap
   IF N_ELEMENTS(minx) EQ 0 THEN minx = MIN(x)
   IF N_ELEMENTS(maxx) EQ 0 THEN maxx = MAX(x)

   retVal = DOUBLE(x - minx) / (maxx - minx)

   IF KEYWORD_SET(cap) THEN BEGIN
       indBelowMin = WHERE(retVal LT 0)
       indAboveMax = WHERE(retVal GT 1)
       
       IF indBelowMin(0) GE 0 THEN retVal(indBelowMin) = 0.
       IF indAboveMax(0) GE 0 THEN retVal(indAboveMax) = 1.
       
   ENDIF

   RETURN, retVal
END
