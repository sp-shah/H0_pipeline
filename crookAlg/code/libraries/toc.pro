; Run Tic & COMMAND & Toc
; Outputs the time interval

PRO Toc

   COMMON TicToc_Store, TimeStamp
   NewTime = SYSTIME(1)

   PRINT, STRING(NewTime - TimeStamp, FORMAT="F7.2")+" sec elapsed"

END
