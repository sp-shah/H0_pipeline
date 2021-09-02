FUNCTION Spher_Harm_Coeff, x, theta, phi, lMax, M=m, L=l, Y=Y, CL=Cl, $
                           WEIGHT=weight, STARTL=lMin
   ; Computes the coefficients for the spherical harmonics up to some lMax
   ; Returns an array with values:
   ; a(0) -> l=0, m=0
   ; a(1,2,3) -> l=1, m=-1,0,1
   ; a(4,5,6,7,8) = ... etc.
   ; Corresponding values of m, l are returned in optional keywords
   ; If lMin is set, then start at lMin
   ; CL is an (lMax-lMin)+1 size array with values of Cl's

   
   IF N_ELEMENTS(weight) EQ 0 THEN weight = REPLICATE(N_ELEMENTS(theta), 1.)
   
   IF N_ELEMENTS(lMin) EQ 0 THEN lMin = 0

   IF lMin LE 0 THEN IgnoreElements = 0 ELSE $
     IgnoreElements = LONG((lMin-1)+1)^LONG(2) 

   NumElements = LONG(lMax+1)^LONG(2) - IgnoreElements
   Y = COMPLEXARR(N_ELEMENTS(theta), NumElements)
   a = COMPLEXARR(NumElements)
   m = INTARR(NumElements)
   l = INTARR(NumElements)
   
   count = LONG(0)
   FOR lValue = lMin, lMax DO BEGIN
       NumMs = 2*lValue + 1
       m(count:count+NumMs-1) = FINDGEN(NumMs) - lValue
       l(count:count+NumMs-1) = REPLICATE(lValue, NumMs)
       count = count + NumMs
   ENDFOR

   FOR i = 0, NumElements-1 DO BEGIN
       PRINT, "l=", l(i), ", m=",m(i)
       Y(*, i) = SPHER_HARM(theta, phi, l(i), m(i), /DOUBLE)
       a(i) = TOTAL(x * Y(*,i)) / TOTAL(Y(*,i) * CONJ(Y(*,i)))
   ENDFOR

   ; Compute Cl Values
   Cl = FLTARR(lMax-lMin+1)
   lValues = FINDGEN(lMax-lMin + 1) + lMin
   lStart = [0,2*lValues+1]

   FOR i = 0, lMax-lMax DO BEGIN
       Cl(i) = TOTAL(a(lStart(i):lStart(i+1)-1) * CONJ(a(lStart(i):lStart(i+1)-1))) / (2*lValue(i)+1)
   ENDFOR

   RETURN, a

END
