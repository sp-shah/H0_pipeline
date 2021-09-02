; Program to determine point in a sorted array where the value is 
; equal to or greater than the input value


; If /UPPER is set then if the value is greater than the largest in
; sortedarray then the final array index is returned

; IF /UNSORTED is set, allows for unsorted arrays

FUNCTION FindValue, Array, Value, UPPER=upper, UNSORTED=unsorted
   ; Use a binary search to pinpoint value
   
   IF KEYWORD_SET(unsorted) THEN BEGIN 
       sortorder = SORT(Array)
       sortedArray = Array(sortorder)
   ENDIF ELSE sortedArray = Array

   ; Initialize 3 pointers:
   LowPointer = 0
   HighPointer = N_ELEMENTS(SortedArray) - 1
   Found = -2

   IF Value GT SortedArray(HighPointer) THEN $
     IF KEYWORD_SET(upper) THEN Found = HighPointer ELSE Found = -1

   IF Value LE SortedArray(LowPointer) THEN Found = 0

   WHILE Found EQ -2 DO BEGIN
       
       MidPointer = CEIL(DOUBLE(HighPointer+LowPointer)/2)

       IF SortedArray(MidPointer) GE Value THEN BEGIN
           ; Check if this is correct stopping point.
           IF SortedArray(MidPointer - 1) LT Value THEN $
             Found = MidPointer ELSE HighPointer = MidPointer - 1
       ENDIF ELSE BEGIN
           LowPointer = MidPointer + 1
       ENDELSE

   ENDWHILE

   IF KEYWORD_SET(unsorted) THEN BEGIN
       Found = sortorder(Found)
   ENDIF
       
   RETURN, Found
   
END
