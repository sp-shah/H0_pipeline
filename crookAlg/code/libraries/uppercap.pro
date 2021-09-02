; If Array(i) > Cap Then Set Array(i) = Cap

FUNCTION UpperCap, Array, Cap
   RetArray = Array
   ind = WHERE(RetArray GT Cap)
   IF ind(0) GE 0 THEN RetArray(ind) = Cap
   RetArray(ind) = Cap

   RETURN, RetArray
END
