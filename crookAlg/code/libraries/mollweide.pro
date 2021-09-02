FUNCTION Mollweide, phi, lambda, lambda0, CENTERB=CenterB, CENTERL=CenterL, $
                    INPUTPA=InputPA, OUTPUTPA=OutputPA, SHOWROTATE=showrotate
  ; Generate the x,y coordinates for a Mollweide map
  ; given the latitude (phi) and longitude (lambda)
  ; of points on a sphere

  ; If given the Position Angles of the objects,
  ; these are recalculated also

  IF N_ELEMENTS(lambda0) EQ 0 THEN lambda0 = 0.

  accuracy = 0.000001 
  ; Accuracy to which coords are desired (Scale: -1.5->1.5)

  IF N_ELEMENTS(CenterB) EQ 0 THEN CenterB = 90.
  IF N_ELEMENTS(CenterL) EQ 0 THEN CenterL = 0.

  IF CenterB NE 90 OR CenterL NE 0 THEN BEGIN
      ; Rotate coords
      CenterCoordsOnPoint, phi, lambda, CenterB, CenterL, phiNew, lambdaNew, PLOT=showrotate
  ENDIF ELSE BEGIN
      phiNew = phi
      lambdaNew = lambda
  ENDELSE

  phi_rad = phiNew*!DTOR
  lambda_rad = lambdaNew*!DTOR
  lambda0_rad = lambda0*!DTOR

  ; Determine the angle theta using Newton-Raphson
  ; where:  2t + sin(2t) = Pi*sin(phi)
 
  ; Provide initial guess:
  theta = ASIN(2*phi_rad/!PI)

  ; Then Iterate
  epsilon = [1.0]
  LastMax = 1.0
  NoConverge = 0

  ConvergeAttempt = 10 ; How many non-convergences before give up
  

  WHILE (MAX(epsilon) GT accuracy) AND (NoConverge LT ConvergeAttempt) DO BEGIN
      epsilon = (!PI*SIN(phi_rad) - 2*theta - SIN(2*theta)) / (2+2*COS(2*theta))
      theta = theta+epsilon
      MaxEpsilon = MAX(epsilon)
      IF LastMax LT MaxEpsilon THEN BEGIN
          NoConverge++
      ENDIF

      LastMax = MaxEpsilon
          
  ENDWHILE

  IF NoConverge GE ConvergeAttempt THEN BEGIN
      PRINT, "Mollweide won't converge at ", MaxEpsilon
      STOP
  ENDIF

  ; Convert Coordinates
  x = -2*SQRT(2)*NumInInterval((lambda_rad - lambda0*!DTOR),-1*!PI,!PI)*COS(theta)/!PI
  y = SQRT(2)*SIN(theta)

  coords = FLTARR(N_ELEMENTS(x),2)
  coords(*,0) = x
  coords(*,1) = y

  IF N_ELEMENTS(InputPA) GT 0 THEN BEGIN
      ; Calculate Position Angles - Does not
      ; work correctly (and - sign in x missing)
      indmZero = WHERE(InputPA EQ !PI/2)
      indmInf = WHERE(InputPA EQ 0)

      m = 1./TAN(InputPA)
      IF indmZero(0) GE 0 THEN m(indmZero) = 0.

      mNew = m*!PI^2*COS(phi_rad) / $
        2*( 4*(COS(theta))^2*(1./COS(phi_rad) + m*(lambda_rad)*TAN(phi_rad)) + $
            (lambda0_rad - lambda_rad)*TAN(theta)*m*!PI*COS(phi_rad))
    
      ; Just for the cases where m = infinity
      IF WhereSize(indmInf) GT 0 THEN BEGIN
          mNew(indmInf) = !PI^2*COS(phi_rad(indmInf)) / $
            2*( 4*(COS(theta))^2*(lambda_rad(indmInf))*TAN(phi_rad(indmInf)) + $
                (lambda0_rad - lambda_rad(indmInf))*TAN(theta)*!PI*COS(phi_rad(indmInf)))
      ENDIF
      
      OutputPA = ATAN(1./mNew)
      IF indmZero(0) GE 0 THEN OutputPA(indmZero) = !PI/2

      OutputPA = NumInInterval(OutputPA, 0., !PI)

  ENDIF

  RETURN, coords

END

PRO TestMollMap
  u = RANDOMU(seed,10000)
  v = RANDOMU(seed,10000)

  lambda = 2*!PI*u
  phi = ACOS(2*v-1) - !PI/2

  mollmap = Mollweide(phi*!RADEG, lambda*!RADEG, 0)

  PLOT, mollmap(*,0), mollmap(*,1), PSYM=3

END
