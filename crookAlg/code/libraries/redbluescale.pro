; Transforms a vector of values between [0...1] to a RGB color
; Blue = 0
; Green = 0.5
; Red = 1

; If EPS is set, then generate similar scheme for ColorTable #13

; IF /THREESTEP is set then color anything 0 < x < 1 green, x>=0 blue, x<=1 red
; If /RESCALE is set, then call Rescale() first with any _EXTRA arguments

FUNCTION RedBlueScale, x0, EPS=eps, THREESTEP=ThreeStep, RESCALE=rescale, _EXTRA=extra
   
   IF KEYWORD_SET(rescale) THEN BEGIN
       x = RescaleValue(x0, _EXTRA=extra) 
   ENDIF ELSE x = x0

   EPS_Blue = 4.*16
   EPS_Green = 11*16
   EPS_Red = 255

   Result = LONARR(N_ELEMENTS(x))
   
   IF KEYWORD_SET(ThreeStep) THEN BEGIN
       indRed = WHERE(x GE 1)
       indBlue = WHERE(x LE 0)
       indGreen = WHERE(x GT 0 AND x LT 1)
       
       IF indRed(0) GE 0 THEN Result(indRed) = KEYWORD_SET(eps) ? EPS_Red : RGB(255,0,0)
       IF indBlue(0) GE 0 THEN Result(indBlue) = KEYWORD_SET(eps) ? EPS_Blue : RGB(0,0,255)
       IF indGreen(0) GE 0 THEN Result(indGreen) = KEYWORD_SET(eps) ? EPS_Green : RGB(0,255,0)
   ENDIF ELSE BEGIN
          
       indLower = WHERE(x LT 0.5, COMPLEMENT=indUpper)
       IF indLower(0) GE 0 THEN BEGIN       
           Result(indLower) = KEYWORD_SET(eps) ? x(indLower)*2 * (EPS_Green-EPS_Blue) + EPS_Blue : RGB(0,255*2*x(indLower), 255*(1-2*x(indLower)))
       ENDIF
       IF indUpper(0) GE 0 THEN BEGIN
           Result(indUpper) = KEYWORD_SET(eps) ? (x(indUpper)-0.5)*2* (EPS_Red-EPS_Green) + EPS_Green :  RGB(255*2*(x(indUpper)-0.5),255*2*(1-x(indUpper)), 0)
       ENDIF
   ENDELSE
      
   RETURN, Result

END
