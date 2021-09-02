; Given Value(r,theta,phi) and r(), theta(), phi()
; Perform 3D interpolation
; First encounter of r-value is used for
; interpolation

PRO FindAboveAndBelow, Haystack, Needle, indAbove, indBelow
   s = SORT(Haystack)
   ind = FindValue(Haystack(s), Values)
   indAbove = s(ind)
   indBelow = s(ind-1)
END

FUNCTION Interpol3DSphere_Grid, Value, r, theta, phi, rNew, thetaNew, phiNew, R3D=r3d
   ; Given a set of values at points defined by 1D arrays of r, theta,
   ; phi (corresponding to Values

   ; Find 4 lines surrounding the point (rNew, thetaNew, phiNew)
   ; and interpolate - 1st in r, then in angle

   ; /R3D: allows r to be 3D array, r(*, theta, phi)

   sortTheta = SORT(theta)
   sortPhi = SORT(phi)

   thetaSorted = theta(sortTheta)
   phiSorted = phi(sortPhi)
  
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
       phiL(indphi360)   = N_ELEMENTS(phi)-1
   ENDIF

   indphi0 = WHERE(phiL LT 0)
   IF indphi0(0) GE 0 THEN BEGIN
       phiL(indphi0)   = N_ELEMENTS(phi)-1
   ENDIF

   ; Take care of points at theta = 0, 180
   indtheta180 = WHERE(thetaU LT 0)
   IF indtheta180(0) GE 0 THEN BEGIN
       thetaL(indtheta180) = N_ELEMENTS(theta)-1       
       thetaU(indtheta180) = N_ELEMENTS(theta)-1
       phiU(indtheta180)   = FindValueArray(phiSorted, NumInInterval(phiL(indtheta180)+!PI, 0, 2*!PI))-1
       
       phiUneg = WHERE(phiU(indtheta180) LT 0)
       IF phiUneg(0) GE 0 THEN phiU(indtheta180(phiUneg)) = N_ELEMENTS(phi)-1
       
   ENDIF

   indtheta0 = WHERE(thetaL LT 0)
   IF indtheta0(0) GE 0 THEN BEGIN
       thetaL(indtheta0) = 0       
       phiL(indtheta0)   = FindValueArray(phiSorted, NumInInterval(phiU(indtheta0)+!PI, 0, 2*!PI))

       phiLneg = WHERE(phiL(indtheta0) LT 0)
       IF phiLneg(0) GE 0 THEN phiL(indtheta0(phiLneg)) = N_ELEMENTS(phi)-1

   ENDIF

   SampleValue = FLTARR(2,2)

   Result = FLTARR(N_ELEMENTS(rNew))

   ; For the case where near phi=360:
   phiSortedU = phiSorted
   phiSortedU(0) = phiSortedU(0) + 2*!PI

   For i = 0L, N_ELEMENTS(rNew)-1 DO BEGIN

       TimeRemaining, FLOAT(i)/N_ELEMENTS(rNew)

       R11 = Value(*,sortTheta(thetaL(i)), sortPhi(phiL(i)))
       R01 = Value(*,sortTheta(thetaL(i)), sortPhi(phiU(i)))
       R00 = Value(*,sortTheta(thetaU(i)), sortPhi(phiU(i)))
       R10 = Value(*,sortTheta(thetaU(i)), sortPhi(phiL(i)))
                
           
       ; Map 4 points to "square"

                               ; Assume values vary linearly across
                                ; shells (instead of planes as in
                                ; linear interpolation)
       
       IF KEYWORD_SET(r3d) THEN BEGIN
           SampleValue(1,0) = INTERPOL_Low(R11, r(*,sortTheta(thetaL(i)), sortPhi(phiL(i))), rNew(i))
           SampleValue(0,0) = INTERPOL_Low(R01, r(*,sortTheta(thetaL(i)), sortPhi(phiU(i))), rNew(i))
           SampleValue(0,1) = INTERPOL_Low(R00, r(*,sortTheta(thetaU(i)), sortPhi(phiU(i))), rNew(i))
           SampleValue(1,1) = INTERPOL_Low(R10, r(*,sortTheta(thetaU(i)), sortPhi(phiL(i))), rNew(i))          
       ENDIF ELSE BEGIN
           SampleValue(1,0) = INTERPOL_Low(R11, r, rNew(i))
           SampleValue(0,0) = INTERPOL_Low(R01, r, rNew(i))
           SampleValue(0,1) = INTERPOL_Low(R00, r, rNew(i))
           SampleValue(1,1) = INTERPOL_Low(R10, r, rNew(i))
       ENDELSE
           
       yL = -rNew(i)*(thetaNew(i) - thetaSorted(thetaL(i)))
       yU = -rNew(i)*(thetaNew(i) - thetaSorted(thetaU(i)))
           
       xL = rNew(i)*SIN(thetaNew(i))*(phiNew(i) - phiSortedU(phiU(i)))
       xU = rNew(i)*SIN(thetaNew(i))*(phiNew(i) - phiSorted(phiL(i)))
           
       Result(i) = Interpol2D(SampleValue, [xL,xU], [yL,yU], 0, 0 )

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

   x = 3.0
   y = 5.
   z = 6.

   CartesianToPolar, x, y, z, r2, th2, ph2

   PRINT, INTERPOL3DSphere_Grid(Value, R, theta, phi, r2, th2, ph2)


   STOP
END
