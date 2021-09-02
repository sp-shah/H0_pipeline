; A fitting function similar to CURVEFIT but robust against outliers
; Removes the furtherst outliers and repeats until the maximum
; standard deviation of an element is MaxSDev (default=2)

; SAMPLEINDEX returns the indices of the elements used in the fit
; DISPERSION returns a measure of error in the fit (StdDev)
; MINRETAIN = Min Fraction of points to keep in the fit

FUNCTION CURVEFIT_Robust, X, Y, Weights, A, Sigma, MAXSDEV=MaxSDev, SAMPLEINDEX=indSample, FITTEDDISPERSION=Deviation, FULLDISPERSION=FullDispersion, FUNCTION_NAME=func, NDISCARDED=nDiscarded, _EXTRA=extra, MINRETAIN=MinRetain

   IF N_ELEMENTS(MaxSDev) EQ 0 THEN MaxSDev = 2
   IF MaxSDev LE 1 THEN BEGIN
       PRINT, "Require: MaxSDev > 1"
       RETURN, -1
   ENDIF

   indSample = INDGEN(N_ELEMENTS(X))
   Done = 0
   count = 0

   IF N_ELEMENTS(MinRetain) GT 0 THEN MaxCount = FLOOR(N_ELEMENTS(X)*(1-MinRetain)) ELSE MaxCount = N_ELEMENTS(X)

   WHILE Done EQ 0 DO BEGIN

       Result = CURVEFIT_Mod(X(indSample), Y(indSample), Weights(indSample), A, Sigma, FUNCTION_NAME=func, _EXTRA=extra)
       
       Offset = Result - Y(indSample)
;       Deviation = STDDEV(Offset)
       Deviation = SQRT(TOTAL(Offset^2) / (N_ELEMENTS(Offset)-1))
       
       MaxOffset = MAX(ABS(Offset), indMax)
       RelOffset = MaxOffset / Deviation
      
       IF RelOffset LT 2 THEN Done = 1
       IF count EQ MaxCount THEN Done = 1

       IF Done EQ 0 THEN BEGIN
           indSample = DeleteArrayElement(indSample, indMax)
           
           IF N_ELEMENTS(indSample) LE 2 THEN BEGIN
               PRINT, "Failed"                            
               RETURN, 0               
           ENDIF

       ENDIF
       
       count++
       
       

   ENDWHILE
   
   CALL_PROCEDURE, func, X, A, F

   Offset = Result - F
   FullDispersion = SQRT(TOTAL(Offset^2) / (N_ELEMENTS(Offset)-1))

   PRINT, "Robust Function Fitting: Used ", 100*FLOAT(N_ELEMENTS(indSample))/N_ELEMENTS(X), "% of points (", STRTRIM(count,2), " iterations), sigma=", STRTRIM(FullDispersion,2), FORMAT="(A,F5.1,A,A,A,F7.2)"
   
   nDiscarded = N_ELEMENTS(X) - N_ELEMENTS(indSample)


   RETURN, F

END
