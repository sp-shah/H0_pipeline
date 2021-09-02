; Stereographic Projection Routine.
; Only tested for Northern Hemisphere

PRO Stereographic, b, l, x, y
   xyrad = COS(b*!DTOR)
   z = SIN(b*!DTOR)
   r = xyrad * 2./(1+z)

   x = r*COS(l*!DTOR)
   y = r*SIN(l*!DTOR)
END
