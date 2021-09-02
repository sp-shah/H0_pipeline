FUNCTION SqrtZero, N
   ; Return the Square-root of N
   ; Unless N < 0, in which case return 0

   Npos = WHERE(N GE 0, COMPLEMENT=Nneg)
   
   Ans = FLTARR(N_ELEMENTS(N))
   IF Npos(0) GE 0 THEN Ans(Npos) = SQRT(N(Npos))
   IF Nneg(0) GE 0 THEN Ans(Nneg) = 0.

   RETURN, Ans

END
