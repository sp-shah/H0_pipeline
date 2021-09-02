
FUNCTION RemoveDuplicate, arrayinput, RETURNVALUES=returnvalues, PRESORTED=presorted, FREQUENCY=frequency, ORDER=sortorder, SORT=sort, TOLERANCE=tolerance

   ; Removes Duplicates in an array, 
   ; Returns only the indices (lowest in the case of duplicates)
   ;   Unless /RETURNVALUES is set
   ; Frequency contains the number of repeats of each value
   ; SortOrder contains the sorted indices (so can be used in
   ;  conjunction with frequency to find all values)

   ; Update: Nov 6, 2007:
   ; If /SORT was previously set, this can be removed 
   ;  (keyword is now redundant)
   ; If it was not set, but data is presorted, /PRESORTED 
   ; can be set to speed it up
   ; If TOLERANCE provided, then assume
   ; numerical values are equal if within tolerance specified

   IF NOT KEYWORD_SET(presorted) THEN BEGIN
       ; Assume Data is Unsorted
       sortorder = SORT(arrayinput)
       sortedarray = arrayinput(sortorder) 
   ENDIF ELSE BEGIN
       ; Assume Data is Sorted
       sortorder = LONG(FINDGEN(N_ELEMENTS(arrayinput)))
       sortedarray = arrayinput
   ENDELSE                                              

   arrayoutput = LONARR(N_ELEMENTS(sortedarray))
   count = LONG(1)

   i = LONG(1)

   IF N_ELEMENTS(tolerance) EQ 0 THEN tolerance = 0

   WHILE (i LT N_ELEMENTS(sortedarray)) DO BEGIN
       diff = 0
       IF tolerance GT 0 THEN BEGIN
           IF ABS(sortedarray(i) - sortedarray(i-1)) GT tolerance THEN diff = 1
       ENDIF ELSE IF (sortedarray(i) NE sortedarray(i-1)) THEN diff = 1

       IF diff EQ 1 THEN BEGIN
           arrayoutput(count) = i
           count++
       ENDIF
       i++
   ENDWHILE
;   arrayoutput(count) = i

   arrayoutput = arrayoutput(0:count-1)
   IF count GT 1 THEN $
     frequency = [arrayoutput(1:count-1), i] - arrayoutput(0:count-1) $
   ELSE frequency = arrayoutput+1
    
   IF KEYWORD_SET(returnvalues) THEN BEGIN
       retArr = sortedarray(arrayoutput)
   ENDIF ELSE BEGIN
       retArr = sortorder(arrayoutput)
   ENDELSE

   RETURN, retArr

END
