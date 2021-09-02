; Waits for User to press enter

PRO PressEnter, Comment, USERBREAK=Bool
   COMMON PressEnter_Store, AutoSkip, WaitTime

   ON_ERROR, 2

   DefaultWaitTime = 1.0 ; Number of seconds to wait if on autocont...

   IF N_ELEMENTS(AutoSkip) EQ 0 THEN AutoSkip = 0
   IF N_ELEMENTS(Comment) EQ 0 THEN Comment = "Press ENTER to continue..." 

   PrintComment = Comment
   IF AutoSkip EQ 1 THEN PrintComment = PrintComment + " (AutoSkip: Press any key to cancel)"

   IF AutoSkip EQ 1 THEN BEGIN

       PRINT, PrintComment

       TimeStart = SYSTIME(2)
       Cont = 0
       WHILE Cont EQ 0 DO BEGIN
           lastletter = GET_KBRD(0)
           IF (SYSTIME(2) - TimeStart) GE WaitTime THEN Cont = 1
           IF lastletter NE "" THEN Cont = 2           
       ENDWHILE
       
       IF Cont EQ 1 THEN BEGIN
           PRINT, "...AutoContinue..."
           RETURN
       ENDIF ELSE BEGIN
           ; Turn of AutoSkip
           PRINT, "AutoSkip Deactivated."
           AutoSkip = 0           
       ENDELSE
       
   ENDIF


   usr_input = ""

   IF !AutoCont EQ 0 THEN BEGIN
       READ, usr_input, PROMPT=Comment
;       IF STRUPCASE(usr_input) EQ "STOP" THEN Bool = 1 ELSE Bool = 0
       words = STRSPLIT(STRUPCASE(usr_input), " ", /EXTRACT)
       
       IF words(0) EQ "STOP" THEN BEGIN
           MESSAGE, "User-requested PROGRAM HALT", LEVEL=-1
       ENDIF ELSE IF words(0) EQ "AUTO" THEN BEGIN
           WaitTime = DefaultWaitTime
           IF N_ELEMENTS(words) GT 1 THEN BEGIN
               IF words(1) EQ '0' THEN WaitTime = 0. $
               ELSE IF FIX(words(1)) GE 1 THEN WaitTime = FLOAT(words(1))
           ENDIF
           
           PRINT, "Activating "+STRTRIM(FIX(WaitTime),2)+"-second autoskip. Cancel at any time by pressing a key..."
           AutoSkip = 1
       ENDIF

   ENDIF ELSE PRINT, "Skipping PRESSENTER"
END
