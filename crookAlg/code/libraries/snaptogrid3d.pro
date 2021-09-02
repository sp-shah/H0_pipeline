; The worst possible 3D interpolation from a scattered grid - just
; assign the nearest value. Only useful if the scattered grid is very
; finely sampled.

; Given grid points {X(i), Y(i), Z(i)} (say you have array F evaluated
; at these points)
; Provide arrays GX, GY, GZ for desired locations (all same size)
; Returns an array same size as GX filled with indices of X to use

; Dist is filled with the distance between the used value and the
; desired location (a measure of the error)

; If specify MaxSep, then it optimizes for separations < MaxSep

FUNCTION SnapToGrid3D, X, Y, Z, GX, GY, GZ, DISTANCE=Dist, MAXSEP=MaxSep

   PRINT, "Snapping to Grid..."

   N = N_ELEMENTS(GX)
   Result = LONARR(N)
   Dist = FLTARR(N)
   Result(*) = -1


   IF N_ELEMENTS(MaxSep) GT 0 THEN BEGIN

       PRINT, "Sorting..."
       MaxSepSq = DOUBLE(MaxSep)^2
       zOrder = SORT(Z)
       
       indGZ = LINDGEN(N)

       PRINT, "Creating Subsets..."

       indZ = FindValueArray( Z(zOrder), [GZ-MaxSep, GZ+MaxSep] , /UPPER)
       indLowerZ = indZ(indGZ)
       indUpperZ = indZ(indGZ+N)

       PRINT, "Finding Nearest Values..."

       FOR i = 0L, N-1 DO BEGIN
       
           TimeRemaining, FLOAT(i)/(N-1), ECO=10
       
           FoundMatch = 0

           indTrial = zOrder(indLowerZ(i):indUpperZ(i))

                                ; Find Nearest Point:
           SepX = GX(i)-X(indTrial)
           SepY = GY(i)-Y(indTrial)
           SepZ = GZ(i)-Z(indTrial)

           indCont = WHERE(ABS(SepY) LT MaxSep AND ABS(SepX) LT MaxSep)

           IF indCont(0) GE 0 THEN BEGIN
               SepSq = SepX(indCont)^2 + SepY(indCont)^2 + SepZ(indCont)^2
 
;           SepSq = SepX^2 + SepY^2 + SepZ^2
        
               MinSep = MIN(SepSq, indNearest)
                            
               Dist(i) = SQRT(MinSep)
               Result(i) = indTrial(indCont(indNearest))
           ENDIF ELSE BEGIN
                                ; Find Nearest Point:
               ; 1st - Try within 10* Max Sep for x, y
               indCont = WHERE(ABS(SepZ) LT 10*MaxSep AND ABS(SepY) LT 10*MaxSep AND ABS(SepX) LT 10*MaxSep)
               IF indCont(0) GE 0 THEN BEGIN
                   SepSq = SepX(indCont)^2 + SepY(indCont)^2 + SepZ(indCont)^2
                   
;           SepSq = SepX^2 + SepY^2 + SepZ^2
                   
                   MinSep = MIN(SepSq, indNearest)
                   
                   Dist(i) = SQRT(MinSep)
                   Result(i) = indTrial(indCont(indNearest))
               ENDIF ELSE BEGIN
                   PRINT, "Long Computation Required."
                   ; No luck, just get nearest point...
                   SepX = GX(i)-X
                   SepY = GY(i)-Y
                   SepZ = GZ(i)-Z
                   SepSq = SepX^2 + SepY^2 + SepZ^2
                   MinSep = MIN(SepSq, indNearest)     
               
                   Dist(i) = SQRT(MinSep)
                   Result(i) = indNearest
               ENDELSE

           ENDELSE

       ENDFOR    

   ENDIF ELSE BEGIN

       FOR i = 0L, N-1 DO BEGIN
           
           TimeRemaining, FLOAT(i)/(N-1)
           
                                ; Find Nearest Point:
           SepX = GX(i)-X
           SepY = GY(i)-Y
           SepZ = GZ(i)-Z
           
           SepSq = SepX^2 + SepY^2 + SepZ^2
           
           MinSep = MIN(SepSq, indNearest)
           Dist(i) = SQRT(MinSep)
           Result(i) = indNearest
           
       ENDFOR

   ENDELSE

   RETURN, Result
   
END
