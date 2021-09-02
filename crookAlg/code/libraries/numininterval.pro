FUNCTION NumInInterval, Num, MinNum, MaxNum
   ; Takes Modulo of number to ensure MinNum <= Num < MaxNum

   Interval = MaxNum-MinNum
   NewNum = ((Num - MinNum) MOD Interval) + MinNum
   StillLess = WHERE(NewNum LT MinNum)
   If StillLess(0) GE 0 THEN NewNum(StillLess) = NewNum(StillLess) + Interval
   
   RETURN, NewNum

END
