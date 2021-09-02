FUNCTION DecimalCel, cmain, cmin, csec

   ; Converts RA in hrs,min,sec to decimal hours
   ; Converts Dec in deg,min,sec to decimal degrees

   DSign = FLTARR(N_ELEMENTS(cmain))
   DSign(*) = 1.
   indNeg = WHERE(STRPOS(cmain,"-") GE 0)
;   indNeg = WHERE(FLOAT(cmain) LT 0)

   IF indNeg(0) GE 0 THEN DSign(indNeg) = -1.

   Decimal = DSign*(ABS(FLOAT(cmain)) + (FLOAT(cmin)/60) + (FLOAT(csec)/3600))

   RETURN, Decimal

END
