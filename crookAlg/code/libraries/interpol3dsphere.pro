; QUITE SLOW!

PRO FindAboveAndBelow, Haystack, Needle, indAbove, indBelow
   s = SORT(Haystack)
   ind = FindValue(Haystack(s), Values)
   indAbove = s(ind)
   indBelow = s(ind-1)
END

FUNCTION Interpol3DSphere, Value, r, theta, phi, rNew, thetaNew, phiNew
   ; Given a set of values at points defined by 1D arrays of r, theta,
   ; phi (corresponding to Values

   ; Find 4 lines surrounding the point (rNew, thetaNew, phiNew)
   ; and interpolate - 1st in r, then in angle
  
   thetaValues = RemoveDuplicate(theta, /RETURNVALUES, TOLERANCE=1e-3)
   thetaSorted = thetaValues(SORT(thetaValues))

   phiValues = RemoveDuplicate(phi, /RETURNVALUES, TOLERANCE=1e-3)
   phiSorted = phiValues(SORT(phiValues))

   ; Find theta above thetaNew
   thetaU = FindValueArray(thetaSorted, thetaNew)

   ; Find phi above phiNew
   phiU = FindValueArray(phiSorted, phiNew)

   ; indices of values below thetaNew & phiNew
   thetaL = thetaU-1
   phiL   = phiU-1

   ; Take care of points at phi = 0, 180
   indphi360 = WHERE(phiU LT 0)
   IF indphi360(0) GE 0 THEN BEGIN
       phiU(indphi360)   = 0
       phiL(indphi360)   = N_ELEMENTS(phiValues)-1
   ENDIF

   indphi0   = WHERE(phiL LT 0)
   IF indphi0(0) GE 0 THEN BEGIN
       phiL(indphi0)   = N_ELEMENTS(phiValues)-1
   ENDIF

   ; Take care of points at theta = 0, 180
   indtheta180 = WHERE(thetaU LT 0)
   IF indtheta180(0) GE 0 THEN BEGIN
       thetaL(indtheta180) = N_ELEMENTS(thetaValues)-1       
       thetaU(indtheta180) = N_ELEMENTS(thetaValues)-1
       phiU(indtheta180)   = FindValueArray(phiSorted, NumInInterval(phiL(indtheta180)+!PI, 0, 2*!PI))-1
       
       phiUneg = WHERE(phiU(indtheta180) LT 0)
       IF phiUneg(0) GE 0 THEN phiU(indtheta180(phiUneg)) = N_ELEMENTS(phiSorted)-1
       
   ENDIF

   indtheta0   = WHERE(thetaL LT 0)
   IF indtheta0(0) GE 0 THEN BEGIN
       thetaL(indtheta0) = 0       
       phiL(indtheta0)   = FindValueArray(phiSorted, NumInInterval(phiU(indtheta0)+!PI, 0, 2*!PI))
   ENDIF

   
   ; Case of too close / too far
;???????????
   
   ; Quadrants:
   ; Q2  Q1
   ; Q3  Q4  
   ; c=close, f=far

   SampleValue = FLTARR(2,2)

   Result = FLTARR(N_ELEMENTS(rNew))
   tol = 1e-3

   ; For the case where near phi=360:
   phiSortedU = phiSorted
   phiSortedU(0) = phiSortedU(0) + 2*!PI

   For i = 0, N_ELEMENTS(rNew)-1 DO BEGIN

       TimeRemaining, FLOAT(i)/N_ELEMENTS(rNew)

       ind1 = WHERE(ABS(theta - thetaSorted(thetaL(i))) LT tol AND ABS(phi - phiSorted(phiL(i))) LT tol)
       ind2 = WHERE(ABS(theta - thetaSorted(thetaL(i))) LT tol AND ABS(phi - phiSorted(phiU(i))) LT tol)
       ind3 = WHERE(ABS(theta - thetaSorted(thetaU(i))) LT tol AND ABS(phi - phiSorted(phiU(i))) LT tol)
       ind4 = WHERE(ABS(theta - thetaSorted(thetaU(i))) LT tol AND ABS(phi - phiSorted(phiL(i))) LT tol)
      
       IF ind1(0) LT 0 OR ind2(0) LT 0 OR ind3(0) LT 0 OR ind4(0) LT 0 THEN BEGIN
           Result(i) = -1
           PRINT, "Unable to interpolate #", i
       ENDIF ELSE BEGIN
           
           
       ; Map 4 points to "square"

                               ; Assume values vary linearly across
                                ; shells (instead of planes as in
                                ; linear interpolation)

           SampleValue(1,1) = INTERPOL(Value(ind1), r(ind1), rNew(i))
           SampleValue(0,1) = INTERPOL(Value(ind2), r(ind2), rNew(i))
           SampleValue(0,0) = INTERPOL(Value(ind3), r(ind3), rNew(i))      
           SampleValue(1,0) = INTERPOL(Value(ind4), r(ind4), rNew(i))
           
       
           yL = -rNew(i)*(thetaNew(i) - thetaSorted(thetaL(i)))
           yU = -rNew(i)*(thetaNew(i) - thetaSorted(thetaU(i)))
           
           xL = rNew(i)*SIN(thetaNew(i))*(phiNew(i) - phiSortedU(phiU(i)))
           xU = rNew(i)*SIN(thetaNew(i))*(phiNew(i) - phiSorted(phiL(i)))
           
           Result(i) = Interpol2D(SampleValue, [xL,xU], [yL,yU], 0, 0 )
       ENDELSE

   ENDFOR


   RETURN, Result

END


PRO TestInterpolSphere

   ; Try and interpolate x-component of polar coordinate.

   N = 50

   Points = [N,N,N]

   R = NumInRange(Points(0),1, 10)
   theta = ACOS(NumInRange(Points(1), -1, 1))
   phi = NumInRange(Points(2), 0, 2*!PI)
   
   Value = FLTARR(N,N,N)  

   FOR i = 0, N-1 DO $
     FOR j = 0, N-1 DO $
     FOR k = 0, N-1 DO $
     Value(i,j,k) = R(i)*SIN(theta(j))*COS(phi(k))

   GridPoints, R, theta, phi, R1, theta1, phi1, VALUE=Value, NEWVALUE=Value1

   x = 3.0
   y = 5.
   z = 6.

   CartesianToPolar, x, y, z, r2, th2, ph2

   PRINT, INTERPOL3DSphere(Value1, R1, theta1, phi1, r2, th2, ph2)


   STOP
END
