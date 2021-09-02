; Takes an array and produces a string of the array elements
; separated by commas

FUNCTION CommaSepArray, Array

   str = ""
   FOR i = 0, N_ELEMENTS(Array)-1 DO BEGIN
       str = str + STRTRIM(STRING(Array(i)),2)
       IF i LT N_ELEMENTS(Array)-1 THEN str=str+","
   ENDFOR
 
   RETURN, str

END
