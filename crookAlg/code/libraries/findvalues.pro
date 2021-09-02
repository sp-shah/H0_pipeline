FUNCTION FindValues, List, Values, REPEATS=Repeats, SLOW=slow, QUIET=quiet, UNSORTED=unsorted
   ; Scans List for Values
   ; Note: Both lists must be sorted unless /UNSORTED keyword is set
   ; Returns an array of indices of same size as Values
   ; Each element contains the index in List of the 1st occurance 
   ; of the value. -1 if none.
   ; 'Repeats' stores the number of values

   IF KEYWORD_SET(unsorted) THEN BEGIN
       indList = SORT(List)
       indValues = SORT(Values)
       SortedList = List(indList)
       SortedValues = Values(indValues)
   ENDIF ELSE BEGIN
       SortedList = List
       SortedValues = Values      
   ENDELSE


   Occurance = LONARR(N_ELEMENTS(SortedValues))
   Repeats = INTARR(N_ELEMENTS(SortedValues))

   Occurance(*) = -1

   i = LONG(0)
   ListStart = LONG(0)

   WHILE i LT N_ELEMENTS(SortedValues) DO BEGIN

       IF NOT KEYWORD_SET(quiet) THEN TimeRemaining, FLOAT(i) / N_ELEMENTS(SortedValues)

       CurrentPointer = FindValue(SortedList(ListStart:N_ELEMENTS(SortedList)-1), SortedValues(i)) + ListStart

       IF CurrentPointer LT ListStart THEN BEGIN
                                ; Reached End of List - All higher
                                ; values not present
           i = N_ELEMENTS(SortedValues)
           
       ENDIF ELSE BEGIN
           IF SortedList(CurrentPointer) EQ SortedValues(i) THEN BEGIN
                                ; Value is not missing
               Occurance(i) = CurrentPointer
                                ; Count how many values there are
               CurrentPointer++
               SearchDone = 0
               WHILE SearchDone EQ 0 DO BEGIN
                   IF CurrentPointer LT N_ELEMENTS(SortedList) THEN BEGIN
                       IF SortedList(CurrentPointer) EQ SortedValues(i) THEN $
                         CurrentPointer++ $
                       ELSE SearchDone = 1
                   ENDIF ELSE SearchDone = 1
               ENDWHILE
               Repeats(i) = CurrentPointer - Occurance(i)
               CurrentPointer--
           ENDIF
           
           ListStart = CurrentPointer
           i++

       ENDELSE
   ENDWHILE

   IF KEYWORD_SET(unsorted) THEN BEGIN
       Occurance1 = LONARR(N_ELEMENTS(SortedValues))
       NoMatch = WHERE(Occurance LT 0, COMPLEMENT=FoundMatch)
       IF NoMatch(0) GE 0 THEN Occurance1(indValues(NoMatch)) = -1
       IF FoundMatch(0) GE 0 THEN Occurance1(indValues(FoundMatch)) = indList(Occurance(FoundMatch))
       RETURN, Occurance1
   ENDIF ELSE RETURN, Occurance   

END
