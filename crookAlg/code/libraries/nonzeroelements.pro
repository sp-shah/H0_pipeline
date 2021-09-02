; Returns all the non-zero elements of the array parsed

FUNCTION NonZeroElements, array
   ; Remove NaNs and zeros
   NonZeroInd = WHERE((array NE 0) AND (array EQ array))

   RETURN, array(NonZeroInd)

END
