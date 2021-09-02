; A Simple convolution routine
; that assumes the PSF is zero outside the specified region
; rather than returning zero for the 1st half of the kernel
; pixels.

FUNCTION SimpleConvolve, A, K, S
  
   IF N_ELEMENTS(S) EQ 0 THEN S = 1
 
   m = N_ELEMENTS(K)
   n = N_ELEMENTS(A)

   HalfM = CEIL(FLOAT(m)/2)

   Result = FLTARR(n)

   FOR t = 0, n-1 DO BEGIN

       iMin = MAX([HalfM - t, 0])

       iMax = MIN([n + HalfM - t - 1, m-1])

       Result(t) = TOTAL(A(t+iMin-HalfM:t+iMax-HalfM)*K(iMin:iMax))
       
   ENDFOR

   RETURN, Result

END
