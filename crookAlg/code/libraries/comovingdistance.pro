; Program to calculate comoving distances
; based on different cosmologies.
;
; Call as:
; ComovingDistance, OmegaM, OmegaR, OmegaV, zMax, [w=-1],
; [zStep=0.01], [h=0.7], [ABSCISSA=z], [Chi=Chi], [x=x], [DA=DA], [DL=DL],
; [dVdz=dVdz], [V=V], [/ALLPOINTS], [/PLOT]
;
; Omega?     Specify the Universe - can be an array
; Chi        Line-of-sight Comoving Distance (D_C in Hogg 2000)
; x          Transverse Comoving Distance    (D_M in Hogg 2000)
; DA         Angular Diameter Distance
; DL         Luminosity Distance
; dVdz       Differential Comoving Volume per unit Solid angle
; V          Total Comoving Volume (all-sky)
; ABSCISSA   Variable to return the redshifts corresponding to the
;            Distance/Volume values (use in conjunction with /ALLPOINTS
; h          Hubble's Constant: H0 = 100h km/s/Mpc
;             If not set, values returned in units of (c/H0)
;             If set, returned in physics units (Mpc, Mpc^3)
; w          P/(rho*c^2) in Dark Energy Equation of
;             State. Default=-1. Can be an array
; ALLPOINTS  If set, all y-values at all values of z will be
;             returned. If not set, only the value at zMax is
;             returned. Use in conjunction with ABSCISSA
; PLOT       Plots graphs of the above quantities as function of z


FUNCTION dChidz, z, OmegaM, OmegaR, OmegaV, OmegaK, w
   ; Calculate dChi/dz for given Universe

   RETURN, 1./SQRT(OmegaM*(1+z)^3 + OmegaR*(1+z)^4 + OmegaV*(1+z)^(3*(1+w)) + OmegaK*(1+z)^2)

END

FUNCTION differential, z, curChi
   ; Returns Derivative dChi/dz

   COMMON codistUniverse, OmegaM, OmegaR, OmegaV, OmegaK, w
   COMMON codistCurParam, curParam

   RETURN, [dChidz(z, OmegaM(curParam), OmegaR(curParam), OmegaV(curParam), OmegaK(curParam), w(curParam))]
END

PRO ComputeChi, zMax, zStep, zRec, Chi, NUniverse

   COMMON codistCurParam, curParam

   MaxNum = CEIL(zMax / zStep) + 1
   Chi = FLTARR(MaxNum, NUniverse)
   zRec = FLOAT(FINDGEN(MaxNum)) * zStep

   Chi(0,*)  = 0.

   U = 0.
   i = LONG(1)

   REPEAT BEGIN
       
       FOR p = 0, NUniverse-1 DO BEGIN
           curParam = p
           dChi = differential(zRec(i), Chi(i-1,p))
           Chi(i,p) = RK4(Chi(i-1,p), dChi, zRec(i), zStep, 'differential')
       ENDFOR
     
       i = i + 1
       
   ENDREP UNTIL i EQ MaxNum

END

FUNCTION Num2String, Number
   ; Converts number to string of form X.XX
   RETURN, STRTRIM(STRING(Number,FORMAT="(F4.2)"),2)
END

PRO PlotLines, OmegaM, OmegaR, OmegaV, w, z, PlotData

   strLegend = STRARR(N_ELEMENTS(OmegaM))
   FOR i = 0, N_ELEMENTS(OmegaM)-1 DO BEGIN
       OPLOT, z, PlotData(*,i), LINESTYLE=i
       strlegend(i) = TexToIDL("(\Omega_M,\Omega_R,\Omega_\Lambda)=(")+Num2String(OmegaM(i))+","+Num2String(OmegaR(i))+","+Num2String(OmegaV(i))+"), w="+ STRTRIM(STRING(w(i)),2)
   ENDFOR
   
   LEGEND, strLegend,LINESTYLE=FINDGEN(N_ELEMENTS(OmegaM)), /TOP, /LEFT, CHARSIZE=0.6

END

PRO PlotGraphs, OmegaM, OmegaR, OmegaV, w, z, zMax, Chi, x, D_A, D_L, dVdz, V
   ; Naive calculation:
   SimpleD = z                     ; in units of c/H0

   !P.MULTI=[0,2,3]
   PLOT, z, Chi, TITLE="Line-of-sight Comoving Distance, Chi vs. z", XTITLE = "z", YTITLE="Chi (c/H!D0!N)", XRANGE=[0,zMax], /NODATA
   PlotLines, OmegaM, OmegaR, OmegaV, w, z, Chi
   OPLOT, z, SimpleD, COL=255
   
   PLOT, z, x, TITLE="Transverse Comoving Distance, x vs. z", XTITLE = "z", YTITLE="x (c/H!D0!N)", XRANGE=[0,zMax], /NODATA
   PlotLines, OmegaM, OmegaR, OmegaV, w, z, x
   OPLOT, z, SimpleD, COL=255      
   
   PLOT, z, D_A, TITLE="Angular Diameter Distance, D!DA!N vs. z", XTITLE = "z", YTITLE="D!DA!N (c/H!D0!N)", XRANGE=[0,zMax], /NODATA
   PlotLines, OmegaM, OmegaR, OmegaV, w, z, D_A
   OPLOT, z, SimpleD, COL=255
   
   PLOT, z, D_L, TITLE="Luminosity  Distance, D!DL!N vs. z", XTITLE = "z", YTITLE="D!DA!N (c/H!D0!N)", XRANGE=[0,zMax], /NODATA
   PlotLines, OmegaM, OmegaR, OmegaV, w, z, D_L
   OPLOT, z, SimpleD, COL=255
   
   PLOT, z, dVdz, TITLE="Differential Comoving Volume per unit solid angle, dV/dzdO vs. z", XTITLE = "z", YTITLE="dV/dz [(c/H!D0!N)!U3!N]", XRANGE=[0,zMax], /NODATA
   PlotLines, OmegaM, OmegaR, OmegaV, w, z, dVdz
   OPLOT, z, SimpleD^2, COL=255
   
   PLOT, z, V, TITLE="Total Comoving Volume per unit solid angle, V vs. z", XTITLE = "z", YTITLE="V [(c/H!D0!N)!U3!N]", XRANGE=[0,zMax], /NODATA
   PlotLines, OmegaM, OmegaR, OmegaV, w, z, V
   OPLOT, z, (4*!PI/3)*SimpleD^3, COL=255
   
   !P.MULTI=0
END

; **********************

PRO ComovingDistance, Omega_M, Omega_R, Omega_V, zMax, w=dubya, zStep=zStep, h=h, PLOT=PLOT, $
                      ALLPOINTS=allpoints, ABSCISSA=z, Chi=retChi, x=retx, DL=retDL, DA=retDA, $
                      dVdz=retdVdz, V=retV

   COMMON codistUniverse, OmegaM, OmegaR, OmegaV, OmegaK, w

   c = 2.9979e5   ; Speed of Light (km/s)

   NUniverse = N_ELEMENTS(Omega_M)

   IF N_ELEMENTS(dubya) EQ 0 THEN dubya = REPLICATE(-1, NUniverse)
   IF N_ELEMENTS(zStep) EQ 0 THEN zStep = 0.01
   IF KEYWORD_SET(allpoints) THEN EndOnly = 0 ELSE EndOnly = 1
   IF N_ELEMENTS(h) EQ 0 THEN DistScale = 1 ELSE DistScale = (c/(100*h))


   OmegaM = Omega_M
   OmegaR = Omega_R
   OmegaV = Omega_V
   OmegaK = 1-OmegaM-OmegaR-OmegaV
   w = dubya

   ; Chi is the line-of-sight comoving distance (units: c/H0)
   ComputeChi, zMax, zStep, z, Chi, NUniverse

   
   x = FLTARR(N_ELEMENTS(z),NUniverse)
   D_A = FLTARR(N_ELEMENTS(z),NUniverse)
   D_L = FLTARR(N_ELEMENTS(z),NUniverse)
   dVdz = FLTARR(N_ELEMENTS(z),NUniverse)
   V = FLTARR(N_ELEMENTS(z),NUniverse)
       

   FOR p=0, NUniverse-1 DO BEGIN
       
       ; x is the transverse comoving distance (units: c/H0)
       IF OmegaK(p) EQ 0 THEN x(*,p) = Chi(*,p) $
       ELSE IF OmegaK(p) LT 0 THEN x(*,p) = SIN(Chi(*,p)*SQRT(ABS(OmegaK(p))))/SQRT(ABS(OmegaK(p))) $
       ELSE x(*,p) = SINH(Chi(*,p)*SQRT(ABS(OmegaK(p))))/SQRT(ABS(OmegaK(p)))

       ; Angular Diameter Distance, D_A (units: c/H0)
       D_A(*,p) = x(*,p) / (1+z)
   
       ; Luminosity Distance, D_L (units: c/H0)
       D_L(*,p) = (1+z) * x(*,p)

       ; Differential Comoving Volume (per unit solid angle) (units: [c/H0]^3)
       dVdz(*,p) = x(*,p)^2 * dChidz(z, OmegaM(p), OmegaR(p), OmegaV(p), OmegaK(p), w(p))
   
       ; Total Comoving Volume  (all-sky) (units: [c/H0]^3)

       IF OmegaK(p) EQ 0 THEN V(*,p) = (4*!PI/3)*x(*,p)^3 $
       ELSE IF OmegaK(p) GT 0 THEN $
         V(*,p) = (4*!PI/(2*OmegaK(p))) * (x(*,p)*SQRT(1+OmegaK(p)*x(*,p)^2) - ASINH(x(*,p)*SQRT(ABS(OmegaK(p))))/SQRT(ABS(OmegaK(p)))) $
       ELSE V(*,p) = (4*!PI/(2*OmegaK(p))) * (x*SQRT(1+OmegaK(p)*x(*,p)^2) - ASIN(x(*,p)*SQRT(ABS(OmegaK(p))))/SQRT(ABS(OmegaK(p))))

   ENDFOR
   
   IF EndOnly EQ 1 THEN BEGIN
       retChi   = FLTARR(NUniverse)
       retx     = FLTARR(NUniverse)
       retDL    = FLTARR(NUniverse)
       retDA    = FLTARR(NUniverse)
       retdVdz  = FLTARR(NUniverse)
       retV     = FLTARR(NUniverse)
       
       FOR p=0, NUniverse-1 DO BEGIN
           retChi(p)   = INTERPOL(Chi, z, zMax) * DistScale
           retx(p)     = INTERPOL(x, z, zMax) * DistScale
           retDL(p)    = INTERPOL(D_L, z, zMax) * DistScale
           retDA(p)    = INTERPOL(D_A, z, zMax) * DistScale
           retdVdz(p)  = INTERPOL(dVdz, z, zMax) * DistScale^3
           retV(p)     = INTERPOL(V, z, zMax) * DistScale^3
       ENDFOR
   ENDIF ELSE BEGIN
       retChi   = Chi * DistScale
       retx     = x * DistScale
       retDL    = D_L * DistScale
       retDA    = D_A * DistScale
       retdVdz  = dVdz * DistScale^3
       retV     = V * DistScale^3
   ENDELSE


   IF KEYWORD_SET(PLOT) THEN BEGIN
       window, 0, xsize=600, ysize=900
       PlotGraphs, OmegaM, OmegaR, OmegaV, w, z, zMax, Chi, x, D_A, D_L, dVdz, V

       SET_PLOT, 'PS'
       DEVICE, filename='cosmology.ps', XSIZE=7.5, YSIZE=10, /PORTRAIT, /COLOR, BITS_PER_PIXEL=8, INCHES=1
       LOADCT, 11
       PlotGraphs, OmegaM, OmegaR, OmegaV, w, z, zMax, Chi, x, D_A, D_L, dVdz, V
       DEVICE, /CLOSE
       SET_PLOT, 'x'

   ENDIF

END


PRO Test
   ComovingDistance, [1.0, 0.05, 0.3, 0.3], [0, 0, 0, 0], [0,0,0.7, 0.7], 0.04, zstep=0.0001, /plot, dl=s, da=d, abscissa=z, h=0.7, /allpoints, w=[-1,-1,-1,-10]

END
