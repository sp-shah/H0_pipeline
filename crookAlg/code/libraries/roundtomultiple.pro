; Rounds the provided number to the nearest multiple of 'MultipleOf'

FUNCTION RoundToMultiple, Number, MultipleOf, FLOOR=floor, CEIL=ceil

   Multiple = FLOAT(Number) / MultipleOf

   IF KEYWORD_SET(floor) THEN BEGIN
       NewMultiple = FLOOR(Multiple)
   ENDIF ELSE IF KEYWORD_SET(ceil) THEN BEGIN
       NewMultiple = CEIL(Multiple)
   ENDIF ELSE BEGIN
       NewMultiple = ROUND(Multiple)
   ENDELSE

   RETURN, NewMultiple * MultipleOf
END
