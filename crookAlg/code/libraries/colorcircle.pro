FUNCTION ColorCircle, Value, Y=Y, RADIUS=Radius, START=Start, FINISH=Finish, COL256=eightbit
   ; Draws a circle in U-V space of specified radius
   ; Pull Points out at specified angle from Starting Angle (0->1)
   ; and ending at specified ending angle (0->1)
   ; Value is a number between 0 and 1 where 0 is start & 1 is end of circle
   ; Spectrum Defined for specified Y (Don't think Y can be > 0.5)

   ; Example:
   ; EnhancedPlot, FINDGEN(100), FINDGEN(100), COL=ColorCircle(FINDGEN(100)/100)

   IF N_ELEMENTS(Y) EQ 0 THEN Y = 0.5
   Y = 0.5

   IF N_ELEMENTS(Radius) EQ 0 THEN Radius = 0.5

   IF N_ELEMENTS(Start) EQ 0 THEN Start = 0.
   IF N_ELEMENTS(Finish) EQ 0 THEN Finish = 1.

   Angle = 2*!PI*( NumInInterval(Value*(Finish - Start) + Start, 0, 1) )

   IF KEYWORD_SET(eightbit) THEN RETURN, FLOOR(Angle*256/(2*!PI))

   U = Radius*SIN(Angle) * 0.436  ; Scaling of U
   V = Radius*COS(Angle) * 0.615   ; Scaling of V

   Yarray = U ; Create array of same dimensions
   Yarray(*) = Y ; Fill with Y

   YUV2RGB, Yarray, U, V, Red, Green, Blue


   RETURN, RGB(Red,Green,Blue)

END
