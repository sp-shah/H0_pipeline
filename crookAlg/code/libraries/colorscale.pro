FUNCTION ColorScale, RGBstart, RGBend, SpacingArray, CenterValue, $
                     FULLSCALE=FullScale

   ; Creates an array of colours centered on CenterValue (N x 3)
   ; Linearscale between RGBstart and RGBend (3-element arrays)
   ; Re-scaled so that either RGBstart or RGBend is included 
   ; in the returned values

   ; Shift array values so center is zero

   ; /FULLSCALE forces RGBstart to coincide with the min value
   ;  and RGBend to coincide with the maximum value

   IF KEYWORD_SET(FullScale) THEN BEGIN
       ScaledArray = 2 * (SpacingArray-MIN(SpacingArray)) / (MAX(SpacingArray)-MIN(SpacingArray)) - 1
   ENDIF ELSE BEGIN
       IF N_ELEMENTS(CenterValue) EQ 0 THEN CenterValue = MEAN(SpacingArray)
       ShiftedArray = SpacingArray - CenterValue

      ; Scale to Maximum Value
       ScaledArray = FLOAT(ShiftedArray) / MAX(ABS(ShiftedArray))
   ENDELSE

   CenterRGB = FLOAT(RGBstart+RGBend) / 2.
   ColorArray =  INTARR(N_ELEMENTS(ScaledArray),3)

   FOR i = 0, 2 DO BEGIN
       ColorArray(*,i) = FIX(CenterRGB(i) + (RGBend(i)-CenterRGB(i))*ScaledArray)
   ENDFOR

   RETURN, RGB(ColorArray(*,0),ColorArray(*,1),ColorArray(*,2))

END
