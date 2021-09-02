; Empties the Keyboard Buffer then returns the next keypress

FUNCTION GetKeyPress

   EmptyKeyboardBuffer
   Ans = ""

   WHILE Ans EQ "" DO BEGIN
       ; Just wait for keypress
       Ans = GET_KBRD(0)
   ENDWHILE

   RETURN, Ans
   
END
