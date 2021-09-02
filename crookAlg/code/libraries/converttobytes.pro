FUNCTION ConvertToBytes, Number, BYTES=bytes, REVERSE=reverse
   ; Converts a number into bytes
   ; As many as required
   ; Usage: Result = ConvertToBytes(Number)
   ; Then Result(i) = Byte(i)
   ; So the number is Byte(N) + 256*Byte(N-1) + ...
   
   ; If BYTES=N is set, then Result will be an array of N values
   
   ; IF /REVERSE is set, then the 0th byte will be the smallest value

   IF NOT KEYWORD_SET(bytes) THEN BEGIN
       ; How many bytes are required to store the number?
       bytes = MAX(CEIL(ALOG(Number) / ALOG(256)))
   ENDIF

   Result = BYTARR(bytes, N_ELEMENTS(Number))
   Remaining = Number

   FOR i = 0, bytes-1 DO BEGIN
       IF KEYWORD_SET(reverse) THEN Index = i ELSE Index = bytes-1-i
       Result(Index, *) = Remaining MOD 256
       IF i LT bytes-1 THEN Remaining = (Remaining - Result(Index, *)) / 256
   ENDFOR

   RETURN, Result

END
