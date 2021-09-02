PRO BoxGraph, x, y, xplot, yplot

   ; Converts a graph of x~y to a square plot:
   ; i.e. y stays at same value until next y specified.

   points = N_ELEMENTS(x)

   yplot = DBLARR(2*points)
   xplot = DBLARR(2*points)
    
   FOR i = 0L, points - 1 DO BEGIN

       xplot(2*i) = x(i)
       IF (i GT 0) THEN yplot(2*i) = y(i-1) ELSE yplot(2*i) = 0

       xplot(2*i + 1) = x(i)
       yplot(2*i + 1) = y(i)

   ENDFOR

END
