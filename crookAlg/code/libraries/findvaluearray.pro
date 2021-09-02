; AS FindValue, but allows Value to be an array of points & conducts
; simultaneous binary searches (6/13/09)

; Program to determine point in a sorted array where the value is 
; equal to or greater than the input value

; If /UPPER is set then if the value is greater than the largest in
; sortedarray then the final array index is returned


FUNCTION FindValueArray, SortedArray, Value, UPPER=upper
   ; Use a binary search to pinpoint value

   N = N_ELEMENTS(Value)
   ; Initialize 3 pointers:

   LowPointer = REPLICATE(0L,N)
   HighPointer = REPLICATE(LONG(N_ELEMENTS(SortedArray)-1),N)
   MidPointer = LowPointer
   Found = REPLICATE(-2L,N)

   indMax = WHERE(Value GT SortedArray(HighPointer))
   IF indMax(0) GE 0 THEN $
     IF KEYWORD_SET(upper) THEN Found(indMax) = HighPointer(indMax) ELSE Found(indMax) = -1

   indMin = WHERE(Value LE SortedArray(LowPointer))
   IF indMin(0) GE 0 THEN Found(indMin) = 0

   indSearching = WHERE(Found EQ -2)

   WHILE indSearching(0) GE 0 DO BEGIN
       
       MidPointer(indSearching) = CEIL(DOUBLE(HighPointer(indSearching)+LowPointer(indSearching))/2)

       indFound = -1
       indGT = WHERE(SortedArray(MidPointer(indSearching)) GE Value(indSearching), COMPLEMENT=indLT)
       IF indGT(0) GE 0 THEN BEGIN
           ; Midpointer above value. check if lower value below...
           indFound = WHERE(SortedArray(MidPointer(indSearching(indGT)) - 1) LT Value(indSearching(indGT)), COMPLEMENT=indCont)
           
           IF indFound(0) GE 0 THEN BEGIN
               ; The following have found their target:
               Found(indSearching(indGT(indFound))) = MidPointer(indSearching(indGT(indFound))) 
           ENDIF
           IF indCont(0) GE 0 THEN BEGIN
               HighPointer(indSearching(indGT(indCont))) = MidPointer(indSearching(indGT(indCont))) - 1
           ENDIF
       ENDIF

       IF indLT(0) GE 0 THEN BEGIN
           LowPointer(indSearching(indLT)) = MidPointer(indSearching(indLT)) + 1
       ENDIF

       IF indFound(0) GE 0 THEN BEGIN
           ; Remove indices of found elements from searching list:
           indSearching = WHERE(Found EQ -2)
;           IF indCont(0) GE 0 THEN indSearching = indSearching(indGT(indCont)) ELSE indSearching = -1
       ENDIF

   ENDWHILE
       
   RETURN, Found
   
END
