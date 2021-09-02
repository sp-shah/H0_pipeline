; Asks the User a Multiple Choice question and will only accept one of
; the requested responses.

FUNCTION MultiChoice, Question, Choices, Default
   ; Default is an optional parameter

   COMMON AutomaticEntry, EntryQueue

   Result = 0
   ForceManual = 0

   IF N_ELEMENTS(EntryQueue) GT 0 THEN AnsLetter = RetrieveFromQueue(EntryQueue)
   WHILE Result EQ 0 DO BEGIN
       usr_input = "" 
       IF N_ELEMENTS(AnsLetter) GT 0 AND ForceManual EQ 0 THEN BEGIN
           PRINT, Question+" "+AnsLetter
           usr_input = AnsLetter
           ForceManual = 1
       ENDIF ELSE READ, usr_input, PROMPT=Question+" "
       
       IF usr_input EQ "" AND N_ELEMENTS(Default) GT 0 THEN BEGIN
           Result = Default
       ENDIF ELSE BEGIN

           FOR i=1, STRLEN(Choices) DO BEGIN
               CurrentChar = STRLOWCASE(STRMID(Choices, i-1, 1))
               IF STRLOWCASE(usr_input) EQ CurrentChar THEN Result = i
           ENDFOR
       ENDELSE
   ENDWHILE

   RETURN, Result

END
