; Rounds the provided number to the nearest number in the list
; provided

FUNCTION RoundToList, Number, List
   Difference = ABS(Number - List)
   MinDiff = MIN(Difference, MatchInd)

   RETURN, List(MatchInd)   
END
