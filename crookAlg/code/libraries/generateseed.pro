; Generates a Seed from the System Clock

FUNCTION GenerateSeed

   curTime = SYSTIME(1)
   curSeconds = LONG(curTime)
   Remaining = curTime-curSeconds
   NanoSec = Remaining*10^(9d)
   Remaining=NanoSec-LONG(NanoSec)
      
   RETURN, LONG(Remaining*10^9d)

END
