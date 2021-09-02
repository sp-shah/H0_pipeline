; Returns 1 for elements in RAlist that are between RALow & RA High
; and 0 for others.
; Allows for wraparound at 24 hrs

FUNCTION RABetween, RAList, RALow, RAHigh
   IF RALow GT RAHigh THEN BEGIN
       RETURN, (RAList GT RALow OR RAList LT RAHigh)
   ENDIF ELSE BEGIN
       RETURN, (RAList GT RALow AND RAList LT RAHigh)
   ENDELSE

END
