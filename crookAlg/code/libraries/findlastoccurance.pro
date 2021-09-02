; Finds the Last occurance of the Needle in the Haystack, return
; Array same size as Needle

FUNCTION FindLastOccurance, Needle, Haystack

   indOccurs = REPLICATE(-1, N_ELEMENTS(Needle))
   j = N_ELEMENTS(Haystack)-1
   WHILE j GE 0 DO BEGIN

       indSubset = WHERE(indOccurs LT 0)
       IF indSubset(0) GE 0 THEN BEGIN
           indFound = WHERE(Needle(indSubset) GE Haystack(j))
           IF indFound(0) GE 0 THEN indOccurs(indSubset(indFound)) = j
           j--
       ENDIF ELSE j = -1

   ENDWHILE

   RETURN, indOccurs

END
