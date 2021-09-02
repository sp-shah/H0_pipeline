FUNCTION PointsOnRange, N, InputArray
   ; Returns N points equally spaced over same range as InputArray

   MaxPoint = MAX(InputArray)
   MinPoint = MIN(InputArray)

   Points = ((MaxPoint-MinPoint)*FLOAT(FINDGEN(N)) / (N-1)) + MinPoint

   RETURN, Points
END
