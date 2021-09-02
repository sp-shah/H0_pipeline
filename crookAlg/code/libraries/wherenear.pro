; RETURNS WHERE(Array NEAR Value)
; NEAR performs comparison |(Array-Value)/Value| < Threshold

FUNCTION WhereNear, Array, Value, Threshold
   Deviation = ABS((Array - Value) / Value)
   RETURN, WHERE(Deviation LT Threshold)
END
