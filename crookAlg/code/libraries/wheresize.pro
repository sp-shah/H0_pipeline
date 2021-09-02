; Determines the size of an array produces using WHERE

FUNCTION WhereSize, Array
   IF Array(0) GE 0 THEN size = N_ELEMENTS(Array) ELSE size = 0
   RETURN, size
END
