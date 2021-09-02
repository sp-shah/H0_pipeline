; Gaussian Random Number generator, but with cutoff at s-sigma

FUNCTION RandomNCutOff, seed, N, s

   Numbers = FLTARR(N)
   indTooBig = FINDGEN(N)

   WHILE indTooBig(0) GE 0 DO BEGIN
       Numbers(indTooBig) = RANDOMN(seed, N_ELEMENTS(indTooBig))
       indTooBig = WHERE(ABS(Numbers) GT s)
   ENDWHILE
   
   RETURN, Numbers

END
