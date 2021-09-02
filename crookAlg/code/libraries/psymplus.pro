FUNCTION PSYMPlus, psym
   ; Creates extra Symbols using the USERSYM command

; *** Standard Symbols ***
   ; 1  = Plus sign (+)
   ; 2  = Asterisk (*)
   ; 3  = Period (.)
   ; 4  = Diamond
   ; 5  = Triangle
   ; 6  = Square
   ; 7  = X
   ; 8  = User-defined. See USERSYM procedure.
   ; 9  = Undefined
   ; 10 = Histogram mode. Horizontal and vertical lines connect the plotted points, as opposed to the normal method of connecting points with straight lines.

; *** Enhanced Symbols ***
   ; 11 = Circle
   ; 12 = Fulled Circle
   ; 13 = Ellipse (horizontal)
   ; 14 = Filled Ellipse (horizontal)

   IF N_ELEMENTS(psym) EQ 0 THEN return, 0

   CASE psym of

       11: BEGIN
           USERSYM_CIRCLE
           retpsym = 8
       END

       12: BEGIN
           USERSYM_CIRCLE, /FILL
           retpsym = 8
       END

       13: BEGIN
           USERSYM_ELLIPSE
           retpsym = 8
       END

       14: BEGIN
           USERSYM_ELLIPSE, /FILL
           retpsym = 8
       END

       ELSE: retpsym = psym

       
   ENDCASE

   RETURN, retpsym


END
