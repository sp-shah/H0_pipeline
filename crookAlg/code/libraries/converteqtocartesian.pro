; Converts RA, Dec to x, y, z values of points on a unit sphere

PRO ConvertEqToCartesian, RA, Dec, x, y, z
   z = SIN(Dec*!DTOR)
   r = COS(Dec*!DTOR)
   x = r*COS(RA*15*!DTOR)
   y = r*SIN(RA*15*!DTOR)
END
