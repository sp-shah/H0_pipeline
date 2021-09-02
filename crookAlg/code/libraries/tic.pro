; Run Tic & COMMAND & Toc
; Outputs the time interval

PRO Tic

   COMMON TicToc_Store, TimeStamp
   TimeStamp = SYSTIME(1)

END
