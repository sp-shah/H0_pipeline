; Returns a string of length l, filled with zeros at the beginning
; Works with arrays

FUNCTION FixLength, n, l, FILLCHAR=fillchar
   str = STRTRIM(STRING(n),2)
   strCurLength = STRLEN(str)

   IF N_ELEMENTS(fillchar) EQ 0 THEN fillchar = STRTRIM(STRING(0),2)
   NumZeros = l - strCurLength

   NumBelowZero = WHERE(NumZeros LT 0)
   IF NumBelowZero(0) GE 0 THEN NumZeros(NumBelowZero) = 0

   ZeroStr = STRARR(MAX(NumZeros)+1)
   ZeroStr(*) = ""
  
   FOR i = 1, N_ELEMENTS(ZeroStr)-1 DO BEGIN
       ZeroStr(i) = fillchar + ZeroStr(i-1)
   ENDFOR

   NewString = ZeroStr(NumZeros) + str

   RETURN, NewString

END
