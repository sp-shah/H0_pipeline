; Returns the length of a 3-D vector (or array of vectors)

FUNCTION VectorLength, V
   Rows = N_ELEMENTS(V(*,0))
   Columns = N_ELEMENTS(V(0,*))

   IF Columns EQ 3 THEN BEGIN
       x = V(*,0)
       y = V(*,1)
       z = V(*,2)
   ENDIF ELSE IF Rows EQ 3 THEN BEGIN
       x = V(0,*)
       y = V(1,*)
       z = V(2,*)
   ENDIF ELSE BEGIN
       PRINT, "Incorrect Vector Size"
       RETURN, -1
   ENDELSE

   Length = SQRT(DOUBLE(x)^2 + DOUBLE(y)^2 + DOUBLE(z)^2)

   RETURN, Length

END
