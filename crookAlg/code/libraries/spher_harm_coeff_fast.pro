FUNCTION Spher_Harm_Coeff_Fast, x, theta, phi, l, M=m, Y=Y, CL=Cl, $
                                WEIGHT=weight
   ; Computes the coefficients for the spherical harmonics of given L
   ; For all m >= 0
   ; Returns Array a_L(m) with elements m <= l

   ; Currently Fails for l > 152 at large m (m>151)
   
   
   IF N_ELEMENTS(weight) EQ 0 THEN weight = REPLICATE(N_ELEMENTS(theta), 1.)
   
   NumElements = l+1
   A = COMPLEXARR(NumElements)
   m = FIX(FINDGEN(NumElements))
  
   mu = COS(DOUBLE(theta))

   FOR k = 0, NumElements-1 DO BEGIN

       LogFactorialFactor = LogFactorial_LowerLimit(l+m(k),l-m(k)+1)
       LogPrefactor = 0.5*(ALOG((2L*l + 1)/(4*!DPI)) - LogFactorialFactor)
                       
;       FactorialFactor = Factorial_LowerLimit(l+m(k),l-m(k)+1)
;       Prefactor = SQRT((2L*l+1) / (4*!DPI * FactorialFactor))

       ; Polar coordinate

       Plm = LEGENDRE(mu, l, m(k), /DOUBLE) ; P(L,M)

; Azimuthal coordinate
       mPhi = M(k)*DOUBLE(phi)

; Compute x*spherharm (real & imag)
       WeightedSpherHarm = Plm*x ; Didn't do weights yet!!
       realPart = TOTAL(WeightedSpherHarm * COS(mPhi))
       imagPart = TOTAL(TEMPORARY(WeightedSpherHarm)*SIN(TEMPORARY(mPhi)))
       
       ; Only use the Plm's within 10 orders
       ; of magnitude from max from now on...

       Beta = MAX(ABS(Plm))
       indKeep = WHERE(ABS(Plm) GT Beta*1e-10)

;       Normalization = TOTAL(Plm^2)
       
       LogNormalization = 2*ALOG(Beta) + ALOG(TOTAL(TEMPORARY(Plm(indKeep)/Beta)^2))

       LogA = ALOG(DCOMPLEX(realPart, imagPart, /DOUBLE)) - LogNormalization - LogPrefactor
       

       A(k) = EXP(LogA)

;       A2 = COMPLEX(TOTAL(realPart), TOTAL(imagPart)) / (Normalization * Prefactor)

       PRINT, "l=", l, ", m=",m(k), ", a(l,m)=", A(k)


stop

   ENDFOR

   ; Compute Cl Values
   Cl = DOUBLE( a(0) * CONJ(a(0)) + 2*TOTAL( a(1:l) * CONJ(a(1:l)) ) ) $
     / (2L*l + 1)


stop
   RETURN, a

END
