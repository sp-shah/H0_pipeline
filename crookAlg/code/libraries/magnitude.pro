FUNCTION Magnitude, data
   ; Computes the Magnitude of a vector
   ; If data is size NxD, return vector size N

   D = N_ELEMENTS(data(0,*))
   N = N_ELEMENTS(data(*,0))

   DataSq = DOUBLE(Data)^2

   IF D EQ 1 AND N GT 1 THEN BEGIN
       Swap, D, N
       DataSq = TRANSPOSE(DataSq)
   ENDIF
  
   SumSqData = DataSq(*,0)
   FOR i = 1, D-1 DO BEGIN
       SumSqData = SumSqData + DataSq(*,i)
   ENDFOR

   Result = SQRT(SumSqData)

   IF N EQ 1 THEN RETURN, TOTAL(Result)

   RETURN, Result

END
