; Re-centers the list of RA's such that mean = 12 hours
; Accounts for possible wrap-arounds at 24 hours

FUNCTION ReCenterRA, RAList, RASHIFT=SubtractHour

   ; Decide if needs to wrap..
   MaxRADiff = MAX(RAList) - MIN(RAList)

   modRA = RAList
   IF MaxRADiff GT 12 THEN BEGIN
       ; Wrap around...
       LowRA = WHERE(modRA LT 12)
       IF LowRA(0) GE 0 THEN modRA(LowRA) = modRA(LowRA) + 24
   ENDIF

   SubtractHour = MEAN(modRA) - 12
   RANew = modRA - SubtractHour

   NegRA = WHERE(RANew LT 0)
   PosRA = WHERE(RANew GE 24)

   IF NegRA(0) GE 0 THEN RANew(NegRA) = RANew(NegRA) + 24
   IF PosRA(0) GE 0 THEN RANew(PosRA) = RANew(PosRA) - 24
   
   RETURN, RANew

END
