; Convolves the PSF with a Gaussian PSF:
; Accepts same options as PSF_GAUSSIAN
; No need to specify NDIMEN
; -- as long as it is 3 !!

FUNCTION GaussianConvolve, PSF, QUIET=quiet, _EXTRA=extra

   s = SIZE(PSF)

   Ndim = s(0)

   IF Ndim NE 3 THEN STOP

   psfGauss = PSF_GAUSSIAN(NDIMEN=1, _EXTRA=extra)
   
   ; Convolve 1 Dimension at a time:
   Result = PSF

   ; Hold y,z constant
   IF NOT KEYWORD_SET(quiet) THEN PRINT, "Stage 1/3"

   StripPSF = FLTARR(s(1))

   FOR i = 0, s(2)-1 DO BEGIN
        IF NOT KEYWORD_SET(quiet) THEN TimeRemaining, FLOAT(i)/s(2)
       FOR j = 0, s(3)-1 DO BEGIN
           StripPSF(*) = Result(*,i,j)
           Result(*,i,j) = SimpleCONVOLVE(StripPSF, psfGauss)        
;           IF j EQ 10 AND i MOD 10 EQ 0 THEN BEGIN
;               PLOT, StripPSF, PSYM=7, LINESTYLE=1
;               OPLOT, psfGauss, COL=RGB(0,255,0)
;               OPLOT, SimpleCONVOLVE(StripPSF, psfGauss), COL=255
;               PressEnter
;           ENDIF
       ENDFOR
   ENDFOR

;stop
    IF NOT KEYWORD_SET(quiet) THEN PRINT, "Stage 2/3"

   ; Hold x,z constant
   StripPSF = FLTARR(s(2))
   FOR i = 0, s(1)-1 DO BEGIN
        IF NOT KEYWORD_SET(quiet) THEN TimeRemaining, FLOAT(i)/s(1)
       FOR j = 0, s(3)-1 DO BEGIN
           StripPSF(*) = Result(i,*,j)
           Result(i,*,j) = SimpleCONVOLVE(StripPSF, psfGauss)
       ENDFOR
   ENDFOR

;stop
    IF NOT KEYWORD_SET(quiet) THEN PRINT, "Stage 3/3"

   ; Hold x,y constant
   StripPSF = FLTARR(s(3))
   FOR i = 0, s(1)-1 DO BEGIN
        IF NOT KEYWORD_SET(quiet) THEN TimeRemaining, FLOAT(i)/s(1)
       FOR j = 0, s(2)-1 DO BEGIN
           StripPSF(*) = Result(i,j,*)
           Result(i,j,*) = SimpleCONVOLVE(StripPSF, psfGauss)
       ENDFOR
   ENDFOR

;stop

   RETURN, Result
      
END
