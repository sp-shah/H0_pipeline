FUNCTION GetLargestConsecutiveRun, Numbers
   ; Looks in array for the largest run of consecutive numbers
   ;  e.g. Numbers=[1,2,4,5,6,7,9,10,12] would return [4,5,6,7]
   ; If there are 2 of identical size -- just take the first one

   NumInRun = 0
   LongestRun = 0
   indRun = 0
   FOR i = 1, N_ELEMENTS(Numbers)-1 DO BEGIN
       IF Numbers(i) EQ Numbers(i-1)+1 THEN BEGIN
           IF NumInRun EQ 0 THEN NumInRun = 2 ELSE NumInRun = NumInRun + 1
       ENDIF ELSE BEGIN
           IF NumInRun GT LongestRun THEN BEGIN
               LongestRun = NumInRun
               indRun = FIX(FINDGEN(LongestRun)) + i - LongestRun
           ENDIF
           NumInRun = 0
       ENDELSE
   ENDFOR
   IF NumInRun GT LongestRun THEN BEGIN
       LongestRun = NumInRun
       indRun = FIX(FINDGEN(LongestRun)) + N_ELEMENTS(Numbers) - LongestRun
   ENDIF
   
   RETURN, indRun

END
