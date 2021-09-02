FUNCTION DeleteArrayElement, Array, index
   ; Returns a 1-D array with the specified element removed
   ; Must have at least 2 elements in the Array
   First = 0
   Last = N_ELEMENTS(array)-1

   IF Last EQ 0 AND index EQ 0 THEN RETURN, -1 ; good enough?

   CASE index OF
       First: RETURN, Array(First+1:Last)
       Last: RETURN, Array(First:Last-1)
       ELSE: RETURN, [Array(First:index-1), Array(index+1:Last)]
   ENDCASE
END
