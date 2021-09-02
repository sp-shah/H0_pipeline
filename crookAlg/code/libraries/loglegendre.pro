Function LogLegendre, X, L, M
;
;     From: thompson@orpheus.nascom.nasa.gov (William Thompson)
;     Date: 26 Feb 1995 19:51:04 GMT
;
;     Let's check parameter first. The function may be called with 2 or
;         3 parameters. The 3rd one defaults to zero.
;
   if N_params(0) lt 2 then begin
           print,'*** LEGENDRE must be called with 2-3 parameters:'
           print,'                 X, L  [, M ]'
           return,X
   end else if N_params(0) eq 2 then M = 0
;
;     Check the value of the parameters ...
;
   if M lt 0 then begin
           print,'*** M must not be less than 0, function LEGENDRE.'
           return,X
   end else if M gt L then begin
           print,'*** M must not be greater than L, function LEGENDRE.'
           return,X
   end else begin
           s = Size(X)
           if s(0) eq 0 then test = abs(x) else test = max(abs(x))
           if test gt 1 then begin
                   print,'*** X must be in the range -1 to 1, function LEGENDRE.'
                   return,X
           endif
   endelse
;
;    Parameters are fine now. As IDL does not optimize code by moving
;    invariant part out of a loop, some temporary variables such as
;    somx2 are defined.
;
   pmm = 1.0 & fact = 1.0
   somx2 = sqrt( (1.0-X) * (1.0+X) )
   for i = 1,M do begin
           pmm = -pmm*fact*somx2
           fact = fact + 2.0
   endfor
;
   if L eq M then $
        PLGNDR = pmm $
   else begin
        pmmp1 = X * (2*M+1) * pmm
        if L eq M+1 then $
             PLGNDR = pmmp1 $
        else begin
             for ll = M+2,L do begin
                 pll = (X*(2*ll-1)*pmmp1 - (ll+M-1)*pmm) / (ll-M)
                 pmm = pmmp1
                 pmmp1 = pll
             endfor
             PLGNDR = pll
        endelse
   endelse
;
   return, ALOG(PLGNDR)
end
