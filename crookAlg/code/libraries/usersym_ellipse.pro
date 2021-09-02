PRO USERSYM_ELLIPSE, majoraxis = majoraxis, color = color, fill = fill, thick = thick, axisratio = axisratio, posangle = posangle

;+
; NAME:
;   ELLIPSE 
; PURPOSE:
;   To make the plotting symbol a circle using USERSYM (psym = 8)
;
; CALLING SEQUENCE:
;   USERSYM_ELLIPSE [, majoraxis = majoraxis, color = color, fill = fill, 
;                    thick = thick, posangle = posangle, axisratio = axisratio]
; INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   MAJORAXIS -- Radius of the circle in character sizes.
;   COLOR -- Color to draw the symbol in (or to FILL with)
;   FILL -- Fill the circle
;   THICK -- Thickness of the border to draw.
;   AXISRATIO -- Axis ratio: b/a
;   POSANGLE -- Angle of Ellipse anticlockwise from vertical
; OUTPUTS:
;


   if n_elements(thick) eq 0 then thick = !p.thick
   if not keyword_set(majoraxis) then majoraxis = 1
   if not keyword_set(axisratio) then axisratio = 1
   if not keyword_set(posangle) then posangle = !PI/2

   a = majoraxis
   b = majoraxis * axisratio

   phi = 2*!PI*FLOAT(FINDGEN(49))/48
   ySym = a*COS(phi)
   xSym = -1*b*SIN(phi)
   IF posangle NE 0 THEN BEGIN
       Rotate, posangle, X=xSym, Y=ySym, NEWX=xNew, NEWY=yNew 
   ENDIF ELSE BEGIN 
       xNew = xSym
       yNew = ySym
   ENDELSE

   USERSYM, xNew, yNew, fill = fill, thick = thick, $
         color = color

END
