; Split data into equal sized bins according to given parameters
; Returns an array of indices pointing to the data (indOrder), as well as 
; an array of pointers to where each bin starts
; NumInBin contains the number in each bin, for convenience

FUNCTION BinByValue, x, NUMBINS=NumBins, INDORDER=indOrder, NUMINBIN=NumInBin, LOGARITHMIC=logarithmic

   IF N_ELEMENTS(NumBins) EQ 0 THEN NumBins = 10
   BinStart = NumInRange(NumBins+1, MIN(DOUBLE(x)), MAX(DOUBLE(x)), LOGARITHMIC=logarithmic)
   
   indOrder = SORT(x)
   
   Pointer = RemoveDuplicate(FindLargerValues(x(indOrder), BinStart), /RETURNVALUES)

   NumBins = N_ELEMENTS(Pointer)-1

   NumInBin = Pointer(1:NumBins) - Pointer(0:NumBins-1)
   NumInBin(NumBins-1)++

   RETURN, Pointer(0:NumBins-1)

END
