FUNCTION GIGamma, m, xMin, xMax, steps, xInterp, yInterp
   ; General Incomplete Gamma Function
   ; Represent Int_xMin^xMax{ x^(m-1).Exp[-x] dx }

   ; This function will only work for finite xMin, xMax

   defSteps = 10000

   IF N_ELEMENTS(steps) EQ 0 THEN steps = defSteps ; Otherwise user-defined
   IF steps EQ 0 THEN steps = defSteps
   uMin = 1 - Exp(DOUBLE(-xMin))
   uMax = MIN([1 - Exp(DOUBLE(-xMax)),1-1e-7])

;   u = uMin + (uMax-uMin) * DOUBLE(FINDGEN(steps)) / (steps-1)
;   u = DOUBLE(FINDGEN(steps)) / (steps)
;   xLog = -ALOG(1-u)
;   x = xMin + (xMax-xMin) * xlog/(MAX(xLog)-MIN(xLog))

   x = xMin * (xMax/xMin)^DOUBLE(FINDGEN(steps)/(steps-1))

   y = x^DOUBLE(m-1) * Exp(-DOUBLE(x))

;   Result = INT_TABULATED(x,y)
   ; Problems with INT_TABULATE: Use Trapezium Integration instead...

   BaseWidth = x(1:steps-1) - x(0:steps-2)
   AvgHeight = 0.5*(y(1:steps-1) + y(0:steps-2))
   Area = BaseWidth*AvgHeight

   Result = TOTAL(Area)

   IF N_PARAMS() GT 4 THEN BEGIN
       ; Compute a set for interpolation
       xInterp = x
       yInterp = DBLARR(steps)
;       yInterp1 = DBLARR(steps)

       yInterp(0) = 0.
;       yInterp1(0) = 0.

       FOR i=1,steps-1 DO BEGIN
           ; Trapezium Method:
           yInterp(i) = yInterp(i-1) + Area(i-1)
;           yInterp1(i) = INT_TABULATED(x(0:i),y(0:i))
       ENDFOR
   ENDIF

   RETURN, Result

END

FUNCTION AdaptiveSteps, MaxDeltaY
   ; Returns a set of x coordinates that correspond to y-coordinates
   ; no more than MaxDeltaY apart.

END

FUNCTION GammaIntegrand, x, m
   y = x^DOUBLE(m-1) * Exp(-DOUBLE(x))
   RETURN, y
END
