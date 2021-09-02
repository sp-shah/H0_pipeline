FUNCTION RandomUnique, seed, N, MaxN
   ; Generate N random Numbers, r: 0<= r < MaxN
   ; with no repetitions

   IF MaxN LT N THEN BEGIN
       PRINT, "Impossible"
       RETURN, -1
   ENDIF

   rand = FLOOR(RANDOMU(seed, N) * MaxN)

   FOR i = 1, N-1 DO BEGIN
       Match = WHERE(rand(0:i-1) EQ rand(i))
       WHILE Match GE 0 DO BEGIN          
           IF Match(0) GE 0 THEN rand(i) = FLOOR(RANDOMU(seed, 1) * MaxN)
           Match = WHERE(rand(0:i-1) EQ rand(i))
       ENDWHILE
   ENDFOR

   RETURN, rand

END
