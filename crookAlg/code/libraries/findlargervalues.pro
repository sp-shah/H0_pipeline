FUNCTION FindLargerValues, SortedList, Values, REPEATS=Repeats
   ; Scans SortedList for Values
   ; Note: 1st List MUST be SORTED
   ; Returns an array of indices of same size as Values
   ; Each element contains the index in SortedList of the 1st occurance 
   ; of the value equal to it, or nearest greater value.

   ; 6/13/09 - NB: The following routine is much faster - if you don't
   ; want the REPEATS.  FindValueArray(SortedList, Values)


   indSorted = SORT(Values)
   SortedValues = Values(indSorted)

   Occurance = LONARR(N_ELEMENTS(SortedValues))
   Occurance(*) = -1

   i = LONG(0)
   ListStart = LONG(0)

   WHILE i LT N_ELEMENTS(SortedValues) DO BEGIN

       CurrentPointer = FindValue(SortedList(ListStart:N_ELEMENTS(SortedList)-1), SortedValues(i)) + ListStart

       IF CurrentPointer LT ListStart THEN BEGIN
                                ; Reached End of List - All higher
                                ; values not present
           i = N_ELEMENTS(SortedValues)
           
       ENDIF ELSE BEGIN
           Occurance(indSorted(i)) = CurrentPointer
           ListStart = CurrentPointer
           i++

       ENDELSE
   ENDWHILE

   RETURN, Occurance

END
