FUNCTION strRight, String, N
   ; Returns the Last N characters of String
   
   StartPos = STRLEN(String) - N
   IF StartPos LT 0 THEN StartPos = 0
   RETURN, STRMID(String, StartPos,N)
END
