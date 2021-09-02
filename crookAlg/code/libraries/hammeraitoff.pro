PRO HammerAitoff, b, l, xMap, yMap, CENTERB=NewCenterB, CENTERL=NewCenterL 

  ; Not yet completed.
   
   zMap = SQRT(1 + COS(b) * COS(l/2))
   xMap = COS(b) * SIN(l/2) / z
   yMap = SIN(b) / z 

END
