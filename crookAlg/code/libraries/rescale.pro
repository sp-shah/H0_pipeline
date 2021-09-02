; Takes an array x
; Returns an array of numbers between 0 and 1 where 0 corresponds to
; the element MIN(x) and 1 corresponds to MAX(x).
; Scaling is linear by default

; Override Min, Max by providing specified values
; If /CAP set, then set anything lower/higher than provided Min/Max to 0/1

FUNCTION ReScale, x, _EXTRA=extra
   RETURN, RescaleValue(x, _EXTRA=extra)

END
