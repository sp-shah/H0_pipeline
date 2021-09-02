FUNCTION RetrieveFromQueue, QueueArray
   ; Takes element (0) of the array and returns it,
   ; while shifting all other elements in the array
   ; towards the start

   IF N_ELEMENTS(QueueArray) NE 0 THEN BEGIN

       Value = QueueArray(0)
       
       FOR i = 0, N_ELEMENTS(QueueArray)-2 DO BEGIN
           QueueArray(i) = QueueArray(i+1)
       ENDFOR

       QueueArray(N_ELEMENTS(QueueArray)-1) = ""
       
       RETURN, Value
   ENDIF ELSE RETURN, ""

END
