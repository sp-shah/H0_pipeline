PRO InterpolatedLF, phiX, phiFit, H0=H0

   ; Brightest/Faintest Abs K-Magnitudes in 2MASS
   magBrightest = -29.4406
   ; -16.92 is faintest
   magFaintest = -16.92


   alpha = -1.020
   M0 = -24.20
   phi0 = 0.003687 *(FLOAT(H0)/70)^3 ;original = 70
   ;PRINT, "Published Values: alpha=-1.02, M0=-24.2, Calculated phi0=", phi0
   
   PhiX = NumInRange(10000, magBrightest, magFaintest)
   phiFit = IntegratedSchechter(PhiX, phi0,M0,alpha)

END

FUNCTION Percolation, galRA, galDec, galV, magLimit, D0, V0, GALDIST=galDist, VF=VF, H0=H0, RENUMBER=renumber, PLOT=plot, SCALEV=ScaleV, QUIET=quiet

   ; Execute percolation Algorithm of HG82 on provided points


   IF N_ELEMENTS(VF) EQ 0 THEN VF = 1000. ; km/s
   IF N_ELEMENTS(H0) EQ 0 THEN H0 = 70.   ; km/s/Mpc ;original = 70

   ;print, "H0"
   ;print, H0
   ;print, "Number of elements in galdist"
   ;print, N_ELEMENTS(GALDIST)

   InterpolatedLF, phiX, phiFit, H0=H0


   Mlim = magLimit - 25 - 5*ALOG10(FLOAT(VF)/H0)
   
   ; Characteristic Integrated Magnitude:
   CharIntMag = INTERPOL(phiFit,phiX,Mlim)
   ;print, "Norm factor"
   ;print, CharIntMag

   IF KEYWORD_SET(plot) THEN BEGIN
       WINDOW, 0
       PLOT, galRA, galDec, PSYM=3, COL=RGB(255,255,255)
   ENDIF

   LookForGalaxy = -1  ; To allow debugging - will stop when it finds this galaxy number
                      ;   (set to -1 for normal use)

   NumGalaxies = N_ELEMENTS(galV)
   ;print, "Num Galaxies in galv"
   ;print, NumGalaxies

   ; Create an array defining group numbers
   galGroup = LONARR(NumGalaxies)
   GroupCount = 0L  ; Counter for highest group number
   ;print, "Number of elemetnst in Galgroup"
   ;print, n_elements(galGroup)

   ; Sort galaxies by velocity:
   galOrder = SORT(galV)
   sortedGalV = galV(galOrder)
   ;print, "Sorted galv"
   ;print, sortedGalv
  
   NumGalaxies = N_ELEMENTS(galV)

   MaxV = sortedGalV(NumGalaxies-1)

   IF N_ELEMENTS(galDist) EQ 0 THEN galDist = galV/H0

;   M12max = magLimit - 25 - 5*ALOG10(MAX(galDist))
;   ScaleFactorMax = (INTERPOL(phiFit,phiX,M12max)/CharIntMag)^(-1./3)
   

   FOR i = 0L, NumGalaxies-2L DO BEGIN
    
       IF NOT KEYWORD_SET(quiet) THEN TimeRemaining, FLOAT(i)/(NumGalaxies-2L)

       galID = galOrder(i)
       ;print, "Galid"
       ;print, galID
       DistEst1 = galDist(galID)
       ;print, "D1"
       ;print, DistEst1
       V1 = sortedGalV(i)
       ;print, "V1"
       ;print, V1
       ;print, "Dec"
       ;print, galDec

;       IF galID EQ LookForGalaxy THEN STOP
       
       IF KEYWORD_SET(ScaleV) THEN BEGIN
           
           MaxVDiff = MaxV - V1
           
           DistEst2max = DistEst1 + MaxVDiff/H0
           
           M12max = magLimit - 25 - 5*ALOG10((DistEst1+DistEst2max)/2)
           ScaleFactor = (INTERPOL(phiFit,phiX,M12max)/CharIntMag)^(-1./3)
           V2max = MaxV < (V1 + V0*ScaleFactor)
           MaxVDiff = V2max - V1

       ENDIF ELSE BEGIN

           ; Create list of comparison objects as those only out to V2=V1+V0
           MaxVDiff = V0     
           V2max = V1 + MaxVDiff
           
          ; Only need to consider galaxies with velocities between V1 & V1 + V0
          ; As galaxies with smaller velocities will already
          ; have been compared with it.
     
       ENDELSE

       MaxVIndex = FindValue(sortedGalV(i+1:NumGalaxies-1),V2max, /UPPER) + i
       ;print, "MaxVindex"
       ;print, MaxVIndex

       IF MaxVIndex GT i THEN BEGIN

                                ; These galaxies are within reach of V1
           CompInd1 = galOrder(i+1:MaxVIndex)
           ;print, "Indices of galaxies that are within the reach of vel"
           ;print, CompInd1
                                ; Determine if any of these galaxies are
                                ; within required spacial separation
           
                                ; Compute maximum separation for any 2
                                ; galaxies:
           
           DistEst2max = DistEst1 + MaxVDiff/H0
           ;print, "DistEst2max"
           ;print, DistEst2max
           M12max = magLimit - 25 - 5*ALOG10((DistEst1+DistEst2max)/2)
           ;print, "M12max"
           ;print, M12max
           ScaleFactor = (INTERPOL(phiFit,phiX,M12max)/CharIntMag)^(-1./3)
           DLmax = D0*ScaleFactor
           ;print, "DLmax"
           ;print, DLmax
;           VLmax = KEYWORD_SET(ScaleV) ? V0*ScaleFactor : V0

           DecSepMax = !RADEG*DLmax / (DistEst1/2)
                                ; Approx Sin(theta)~theta - to throw
                                ;                           away non-matches quickly.
           ;print, "DecSepMax"
           ;print, DecSepMax
           
;        ;PRINT, "Reduced to : ", N_ELEMENTS(CompInd2)," from ", N_ELEMENTS(CompInd1)
           
           CompInd2 = WHERE(ABS(galDec(CompInd1) - galDec(galID)) LT DecSepMax)
           ;print, "Gal dec2"
           ;print, galDec(CompInd1)
           ;print, "Galdec1"
           ;print, galDec(galID)
           ;print, "dec difference"
           ;print, ABS(galDec(CompInd1) - galDec(galID))
           ;print, "compind2"
           ;print, CompInd2
           IF CompInd2(0) GE 0 THEN BEGIN
               CompareIndex = CompInd1(CompInd2)
               ;print, "ra and dec of the galaxies being compared"
               ;print, galDec(CompareIndex)
               ;print, galRA(CompareIndex)
               AngularSep = AngSep(galRA(galID),galDec(galID),galRA(CompareIndex),galDec(CompareIndex))
               ;print, "Angular Separation"
               ;print, AngularSep
               DistAvg = (DistEst1 + galDist(CompareIndex))/2
               ;print, "DistAvg"
               ;print, DistAvg
;            Vavg = (V1+galV(CompareIndex))/2
               D12 = 2*SIN(AngularSep/2) * DistAvg
               ;print, "D12"
               ;print, D12
                                ; Calculate Max Separation (DL) for these 2 galaxies
               
               M12 = magLimit - 25 - 5*ALOG10(DistAvg)
               ;print, "M12"
               ;print, M12
               MagScale = (INTERPOL(phiFit,phiX,M12)/CharIntMag)^(-1./3)
               
               DL = D0*MagScale
               ;print, "DL"
               ;print, DL
               IF KEYWORD_SET(ScaleV) THEN BEGIN
                   V12 = ABS(galV(CompareIndex)-V1)
                   VL = V0*MagScale
                   CloseInd = WHERE(D12 LE DL AND V12 LE VL)
               ENDIF ELSE BEGIN
                   CloseInd = WHERE(D12 LE DL) ; Within desired distance on sky.
                   ;print, "CloseInd"
                   ;print, CloseInd
               ENDELSE
               
               If CloseInd(0) GE 0 THEN BEGIN
                   
                   CompareID = CompareIndex(CloseInd) 
                                ; ID numbers of all galaxies to be grouped
                   

                                ; All galaxies are in the same group.
                                ; We must now go through and convert
                                ; ALL galaxies in the sample with group numbers present in this
                                ; subsample to the same number.
                   
                                ; Create array of the galaxies in subsample
                                ; that are already in groups:
                   InGroups = WHERE(galGroup(CompareID) GT 0, COMPLEMENT=NotInGroups)
                   
                                ; Determine if 1st galaxy is already part of a group
                
                   IF (galGroup(galID) GT 0) THEN BEGIN
                                ; Already in a group - select this group number
                       curGroup = galGroup(galID)    
                   ENDIF ELSE BEGIN
                                ; Not yet in group - If possible, assign to a pre-existing group
                       
                       If InGroups(0) LT 0 THEN BEGIN
                           
                                ; No pre-existing groups
                                ; Create a new one one & add first galaxy
                           
                           GroupCount++
                           curGroup = GroupCount
                           galGroup(galID) = curGroup
                           
                       ENDIF ELSE BEGIN
                           
                                ; galID Not yet in a group, but
                                ; Found a pre-existing group from matches
                                ; Select this group number
                           
                           curGroup = galGroup(CompareID(InGroups(0)))
                           galGroup(galID) = curGroup
                           
                       ENDELSE

                   ENDELSE
                
                   IF KEYWORD_SET(plot) THEN $
                     OPLOT, galRA(CompareID), galDec(CompareID), PSYM=3, COL=ColorCircle(FLOAT(curGroup)/5000)

                   
                   ; Put galaxies with no group assigments in curGroup:
                   
                   IF NotInGroups(0) GE 0 THEN BEGIN
                       galGroup(CompareID(NotInGroups)) = curGroup
                       
                       IF WhereSize(WHERE(CompareID(NotInGroups) EQ LookForGalaxy)) GT 0 THEN STOP
                       
                   ENDIF
                   
                   ; Convert group numbers of remaining galaxies:
                   IF InGroups(0) GE 0 THEN BEGIN
                       SwitchGroup = galGroup(CompareID(InGroups))
                       SwitchGroup = RemoveDuplicate(SwitchGroup, /SORT, /RETURNVALUES)
                       
                       FOR s = 0, N_ELEMENTS(SwitchGroup)-1 DO BEGIN
                           IF SwitchGroup(s) NE curGroup THEN BEGIN
                               indConvert = WHERE(galGroup EQ SwitchGroup(s))
                               galGroup(indConvert) = curGroup
                               IF KEYWORD_SET(plot) THEN $
                                 OPLOT, galRA(indConvert), galDec(indConvert), PSYM=3, COL=ColorCircle(FLOAT(curGroup)/5000)
                           ENDIF
                       ENDFOR
                   ENDIF
                   
               ENDIF

           ENDIF
       ENDIF
       
   ENDFOR


   IF KEYWORD_SET(renumber) THEN galGroup = ReNumberGroups(galGroup)
   
   RETURN, galGroup

END
