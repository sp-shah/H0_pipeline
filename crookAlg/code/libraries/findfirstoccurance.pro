; Finds the First occurance of the Needle in the Haystack, return
; Array same size as Needle

FUNCTION FindFirstOccurance, Needle, Haystack

   indOccurs = REPLICATE(-1, N_ELEMENTS(Needle))
   j = 0
   WHILE j LT N_ELEMENTS(Haystack) DO BEGIN

       indSubset = WHERE(indOccurs LT 0)
       IF indSubset(0) GE 0 THEN BEGIN
           indFound = WHERE(Needle(indSubset) LE Haystack(j))
           IF indFound(0) GE 0 THEN indOccurs(indSubset(indFound)) = j
           j++
       ENDIF ELSE j = N_ELEMENTS(Haystack)      

   ENDWHILE

   RETURN, indOccurs

END
