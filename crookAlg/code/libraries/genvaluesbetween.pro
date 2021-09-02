; Generates N values between A & B (including A & B)
; If A > B then points appear in descending order

FUNCTION GenValuesBetween, A, B, N
   Points = ABS(B-A) * FLOAT(FINDGEN(N)) / (N-1) + MIN([A,B])
   IF A GT B THEN Points = REVERSE(Points)

   RETURN, Points

END
