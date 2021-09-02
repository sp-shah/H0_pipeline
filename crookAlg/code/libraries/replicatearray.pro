FUNCTION ReplicateArray, Array, COLS=cols, ROWS=rows
   ; Like REPLICATE, only works on 1-D arrays
   ; Either cols or rows must be set to non-zero number
   ; Will replicate the array with that many rows/columns
   ; Each identical to the 1-D array and outpur a 2-D array

   IF KEYWORD_SET(cols) THEN BEGIN
       Result = DBLARR(N_ELEMENTS(Array), cols)
       FOR i = 0, cols-1 DO BEGIN
           Result(*, i) = Array
       ENDFOR
   ENDIF ELSE IF KEYWORD_SET(rows) THEN BEGIN
       Result = DBLARR(rows, N_ELEMENTS(Array))
       FOR i = 0, rows-1 DO BEGIN
           Result(i, *) = Array
       ENDFOR
   ENDIF ELSE BEGIN
       Result = Array
   ENDELSE

   RETURN, Result

END
