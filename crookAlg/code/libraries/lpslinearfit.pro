; Least Perpendicular Squares Fit (linear)
; Minimizes the perpendicular distance of the points from a line

FUNCTION LPSLinearFit, x, y, ORIGIN=origin, SIGMA=sigma

   IF NOT KEYWORD_SET(origin) THEN BEGIN
       ; Move points so that centered at (0,0)
       xCenter = MEAN(x)
       yCenter = MEAN(y)
   ENDIF ELSE BEGIN
       xCenter = 0
       yCenter = 0
   ENDELSE

   x1 = x - xCenter
   y1 = y - yCenter

   ; Perform Perpendicular Regression of the Line
   
   ; Solution to  tan(q)^2  +  A tan(q) - 1  =  0
   ; where A = {x1^2-y1^2}/{x1 y1}. and {..} indicates SUM

   A = TOTAL(x1^2 - y1^2) / TOTAL(x1*y1)

   TanQ_Upper = (-A + SQRT(A^2 + 4)) / 2
   TanQ_Lower = (-A - SQRT(A^2 + 4)) / 2

   Q_Upper = ATAN(TanQ_Upper)
   Q_Lower = ATAN(TanQ_Lower)

   PerpOffset_U = SQRT(TOTAL( (-x*SIN(Q_Upper) + y*COS(Q_Upper))^2 ))
   PerpOffset_L = SQRT(TOTAL( (-x*SIN(Q_Lower) + y*COS(Q_Lower))^2 ))
   
   IF (PerpOffset_U LT PerpOffset_L) THEN BEGIN
       TanQ = TanQ_Upper
       Sigma = PerpOffset_U / SQRT(N_ELEMENTS(x))
   ENDIF ELSE BEGIN
       TanQ = TanQ_Lower
       Sigma = PerpOffset_L / SQRT(N_ELEMENTS(x))
   ENDELSE

   C = yCenter - TanQ*xCenter

   RETURN, [C, TanQ]

END
