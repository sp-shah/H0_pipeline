FUNCTION ConvertFromBytes, ByteArray, REVERSE=reverse
   ; Given a number ByteArray
   ; Compute ByteArray(N) + 256*ByteArray(N-1) + ...
   ; Set /REVERSE if 0th byte is smallest value

   Result = LONARR(N_ELEMENTS(ByteArray(0,*)))

   FOR i = 0, N_ELEMENTS(ByteArray(*,0))-1 DO BEGIN
       Power = i
       IF KEYWORD_SET(reverse) THEN $
          Power = i $
       ELSE Power =  N_ELEMENTS(ByteArray(*,0))-1-i

       Result = Result + ByteArray(i,*)*LONG(256)^Power
   ENDFOR

   RETURN, Result

END
