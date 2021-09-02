; Generates a series of integers from StartNum, to EndNum (inclusive)
FUNCTION GenerateIntegers, StartNum, EndNum
   RETURN, FINDGEN(EndNum-StartNum+1) + StartNum
END
