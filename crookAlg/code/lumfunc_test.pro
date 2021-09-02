PRO Interpolated

   ; Brightest/Faintest Abs K-Magnitudes in 2MASS
   magBrightest = -29.4406
   ; -16.92 is faintest
   magFaintest = -16.92
   H0 = 73.
   VF = 1000.
   magLimit = 11.25

   alpha = -1.020
   M0 = -24.20
   phi0 = 0.003687 *(FLOAT(H0)/70.)^3.
   PRINT, "Published Values: alpha=-1.02, M0=-24.2, Calculated phi0=", phi0
   
   PhiX = NumInRange(10000, magBrightest, magFaintest)
   phiFit = IntegratedSchechter(PhiX, phi0, M0, alpha)
   
   Mlim = magLimit - 25. - 5.*ALOG10(FLOAT(VF)/H0)
   norm_factor = INTERPOL(phiFit, phiX, Mlim)
   
   ;------------------------------------------
   D1 = 137.67
   ra1 = 3.166
   dec1 = 19.21

   D2 = 140.99
   ra2 = 3.174
   dec2 = 19.61
   ;d3 = 
   ;ra3 = 
   ;dec3 = 
   ;D4 = 134.62
   ;ra4 = 0.25458
   ;dec4 = -57.245

   D0 = 0.56
   ;--------------------------------------------
   Davg = (D1 + D2)/2.
   print, "Davg"
   print, Davg
   M12 = magLimit - 25. - 5.*ALOG10(Davg)
   print, "M12"
   print, M12
   denominator = INTERPOL(phiFit, phiX, M12)
   print, "Denominator"
   print, denominator
   print, "Dl"
   Dl = D0*(norm_factor/denominator)^(1./3.)
   print, Dl
   print, "Angsep"
   angularsep = AngSep(ra1, dec1, [ra2], [dec2])
   print, angularsep
   D12 = 2.*SIN(angularsep/2.)*Davg
   print, "D12"
   print, D12
   print, "Norm factor"
   print, norm_factor           ;0.014766891 with H0=73
   
   
   ;p = plot(PhiX, phiFit)
   ;writecol, "lumfunc_values.txt", PhiX, phiFit
   
END
