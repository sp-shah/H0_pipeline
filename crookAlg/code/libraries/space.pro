FUNCTION Space, N, CHAR=char
   ; Returns a string that is N spaces long
   Result = ""
   IF NOT KEYWORD_SET(char) THEN char = " "

   FOR i = 1, N DO BEGIN
       Result = Result + char
   ENDFOR

   RETURN, Result

END
