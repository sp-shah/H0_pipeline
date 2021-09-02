FUNCTION DotP, V1, V2
   ; Compute dot product between 2 N-elements vectors

   RETURN, TOTAL( (TRANSPOSE(V1) # V2) )

END
