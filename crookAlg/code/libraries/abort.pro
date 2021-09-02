FUNCTION Abort, AbortString, RESET=reset
   ; Function that tests to see if user
   ; has hit the 'abort' string on the keyboard (Default: QQQ)
   ; Keyboard buffer cleared after executing

   ; /RESET Forces the OldBuffer to be wiped

   COMMON Store_Abort, OldBuffer

   IF N_ELEMENTS(AbortString) EQ 0 THEN AbortString = "QQQ"
   IF N_ELEMENTS(OldBuffer) EQ 0 THEN OldBuffer = ""

   IF KEYWORD_SET(reset) THEN OldBuffer = ""

   Found = 0

   LastLetter = " "
   WHILE LastLetter NE "" DO BEGIN
       LastLetter = GET_KBRD(0)
       IF LastLetter NE "" THEN BEGIN
           OldBuffer = OldBuffer + LastLetter           
       ENDIF
   ENDWHILE
   
   lBuffer = STRLEN(OldBuffer)
   lString = STRLEN(AbortString)

   IF lBuffer GE lString THEN BEGIN
       OldBuffer = STRUPCASE(STRMID(OldBuffer, lBuffer-lString))
       IF OldBuffer EQ STRUPCASE(AbortString) THEN BEGIN
           OldBuffer = ""
           Found = 1
       ENDIF
   ENDIF

   RETURN, Found

END

PRO TestAbort

   WHILE 1 EQ 1 DO BEGIN
       WAIT, 1.
       IF Abort() THEN STOP
   ENDWHILE

END
