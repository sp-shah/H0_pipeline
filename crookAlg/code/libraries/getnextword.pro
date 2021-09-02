FUNCTION GetNextWord, str, REMAINDER=remainder, SEPARATOR=char, MAXLENGTH=maxlen
  ; Returns the next word (no spaces) marked by separator provided (space
  ; by default)
  ; char may be an array of all possible separators
  ; maxlen is maximum word length

  IF N_ELEMENTS(char) EQ 0 THEN char = " "

  strTrimmed = STRTRIM(str, 1)

  NextPos = STRLEN(strTrimmed)
  FOR j = 0, N_ELEMENTS(char)-1 DO BEGIN
      FoundPos = STRPOS(strTrimmed, char(j))
      IF FoundPos GE 0 THEN NextPos = MIN([NextPos, FoundPos])
  ENDFOR
  
  IF N_ELEMENTS(maxlen) GT 0 THEN NextPos = MIN([NextPos, 2])

  NextWord = STRMID(strTrimmed, 0, NextPos)
  
  remainder = STRMID(strTrimmed, NextPos)

  RETURN, NextWord

END
