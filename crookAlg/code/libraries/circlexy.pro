PRO CircleXY, Radius, x, y, POINTS=N, XCENTER=xcenter, YCENTER=ycenter
   ; Returns coordinates of a circle made from N points
   ; centered at XCENTER, YCENTER

   IF NOT KEYWORD_SET(N) THEN N = 200
   IF NOT KEYWORD_SET(xcenter) THEN xcenter = 0
   IF NOT KEYWORD_SET(ycenter) THEN ycenter = 0
   
   Angles = 2*!PI*FINDGEN(N)/(N-1)

   x = Radius * COS(Angles) + xcenter
   y = Radius * SIN(Angles) + ycenter

END
