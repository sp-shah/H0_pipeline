; If Array(i) < Cap then set Array(i) = Cap

FUNCTION LowerCap, Array, Cap
   RetArray = Array
   ind = WHERE(RetArray LT Cap)
   IF ind(0) GE 0 THEN RetArray(ind) = Cap

   RETURN, RetArray
END
