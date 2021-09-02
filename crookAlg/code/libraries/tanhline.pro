; A Function that is linear for x<<exp[p] with gradient of m, and flat
; for x>>exp[p]

; y = (m exp[p]) tanh(x/ exp[p])

PRO TanhLine, x, Param, F, pder
   ; Straight Line that passes through origin with gradient Param(0)
   ; Can be used in curve-fitting procedures
   m = Param[0]
   p = Param[1]
   
   ; If p > 100, treat as infinite:

   ; If the procedure is called with four parameters, calculate the partial derivative:

   IF p LT 10 THEN BEGIN

       expp = EXP(p)
       F1 = expp * TANH( x / expp )   
       F  = m * F1

       IF N_PARAMS() GE 4 THEN BEGIN
           dm = F1
           dp = F - (m*x) / (COSH(x / expp))^2
       ENDIF
       
   ENDIF ELSE BEGIN

       F = m*x
       
       IF N_PARAMS() GE 4 THEN BEGIN
           dm = x
           dp = m*x^3 / (2*Exp(2*p))
       ENDIF

       
   ENDELSE

   IF N_PARAMS() GE 4 THEN BEGIN
       indZero = WHERE(ABS(dp) LT 1e-20)
       IF indZero(0) GE 0 THEN dp(indZero) = 1e-20*Sign(dP(indZero))
       indZero = WHERE(ABS(dm) LT 1e-20)
       IF indZero(0) GE 0 THEN dm(indZero) = 1e-20*Sign(dm(indZero))
       pder = [[dm], [dp]]
   ENDIF


END
