; Converts a string such as "03 34 45.7 -00 67 90" into RA (decimal
; hrs) and Dec (decimal deg)


PRO RADecFromString, strIn, RA, Dec

   N = N_ELEMENTS(strIn)

   RA = FLTARR(N)
   Dec = FLTARR(N)

   FOR i = 0, N-1 DO BEGIN
       ; Traverse String
       curStr   = strIn(i)
       RA_Hour  = GetNextWord(curStr, REMAINDER=remStr, MAXLENGTH=2) & curStr = remStr
       RA_Min   = GetNextWord(curStr, REMAINDER=remStr, MAXLENGTH=2) & curStr = remStr
       RA_Sec   = GetNextWord(curStr, REMAINDER=remStr, SEPARATOR=[" ","+","-"]) & curStr = remStr

       Dec_Sign = STRTRIM(GetNextWord(curStr, REMAINDER=remStr, SEPARATOR=STRTRIM(FIX(FINDGEN(10)),2)),2) & curStr = remStr

       Dec_Hour = GetNextWord(curStr, REMAINDER=remStr, MAXLENGTH=2) & curStr = remStr
       Dec_Min  = GetNextWord(curStr, REMAINDER=remStr, MAXLENGTH=2) & curStr = remStr
       Dec_Sec  = GetNextWord(curStr, REMAINDER=remStr) & curStr = remStr

       RA(i)  = TEN(FLOAT(RA_Hour), FLOAT(RA_Min), FLOAT(RA_Sec))
       Dec(i) = ABS(TEN(FLOAT(Dec_Hour), FLOAT(Dec_Min), FLOAT(Dec_Sec)))

       IF Dec_Sign EQ "-" THEN Dec(i) = -1*Dec(i)      

   ENDFOR

   IF N EQ 1 THEN BEGIN
       RA = RA(0)
       Dec = Dec(0)
   ENDIF

END
