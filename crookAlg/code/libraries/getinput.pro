; Asks the User a question, response is capitalized.
; Repeats question if default is blank
; Inserts default reponse if defauly is filled

FUNCTION GetInput, Question, Default
   ; Default is an optional parameter

   COMMON AutomaticEntry, EntryQueue

   Result = ""
   IF N_ELEMENTS(Default) GT 0 THEN DefaultStr = STRTRIM(STRING(Default),2)
   IF N_ELEMENTS(EntryQueue) GT 0 THEN Answer = RetrieveFromQueue(EntryQueue)

   ForceManual = 0

   WHILE Result EQ "" DO BEGIN
       usr_input = "" 
       DisplayPrompt = Question + " "
       
       IF N_ELEMENTS(Default) GT 0 THEN $
         DisplayPrompt = DisplayPrompt + "(Default="+DefaultStr+") "
       
       IF N_ELEMENTS(Answer) GT 0 AND ForceManual EQ 0 THEN BEGIN
           PRINT, DisplayPrompt + Answer
           usr_input = Answer
           ForceManual = 1
       ENDIF ELSE READ, usr_input, PROMPT=DisplayPrompt
       
       IF usr_input EQ "" AND N_ELEMENTS(Default) GT 0 THEN BEGIN
           Result = DefaultStr
       ENDIF ELSE BEGIN
           IF usr_input NE "" THEN Result = STRLOWCASE(STRTRIM(usr_input,2))  
       ENDELSE
   ENDWHILE

   RETURN, Result

END
