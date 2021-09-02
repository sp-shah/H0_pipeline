; RETURNS y, interpolated at x (x1 < x < x2)

FUNCTION TwoPointInterp, x1, x2, y1, y2, x
   y = (x-x1) * (y2-y1)/(x2-x1) + y1
   RETURN, y
END
