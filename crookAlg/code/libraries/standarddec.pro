; Converts a Decimal Dec into the standard format used in tables:
; e.g. DD MM SS.S

FUNCTION StandardDec, DecimalDec, decimals, NOSPACE = nospace, $
                      SEPARATOR = separator, LATEX = latex
   IF N_PARAMS() EQ 1 THEN decimals=1

   DecSeconds = ABS(DecimalDec*3600)

   dSign = REPLICATE("+",N_ELEMENTS(DecimalDec))
   SignNeg = WHERE(DecimalDec LT 0)
   IF SignNeg(0) GE 0 THEN dSign(SignNeg) = "-"

   RoundedDec = DOUBLE(LONG(DecSeconds*(10^decimals) + 0.5)) / (10^decimals)

   Decdeg = FIX(RoundedDec/3600)
   Decminute = FIX((RoundedDec - LONG(Decdeg)*3600)/60)
   Decsecond = FIX(RoundedDec - LONG(Decdeg)*3600 -LONG(Decminute)*60)

   Decdecimalsec = FIX( (RoundedDec - LONG(Decdeg)*3600 - LONG(Decminute)*60 - LONG(Decsecond))*10^decimals)

   strSecond = FIXLENGTH(Decsecond,2)
   IF decimals GT 0 THEN BEGIN
       strSecond=strSecond+"."+FIXLENGTH(Decdecimalsec,decimals)
   ENDIF

   IF KEYWORD_SET(nospace) THEN separator = "" ELSE BEGIN
       IF NOT KEYWORD_SET(separator) THEN separator = " "
   ENDELSE
      
   IF KEYWORD_SET(latex) THEN BEGIN
       strOut = "$"+dSign+"$"+FIXLENGTH(Decdeg,2)+"$^\circ$"+FIXLENGTH(Decminute,2)+"$'$"+strSecond+"$''$"

   ENDIF ELSE BEGIN
       
       strOut = dSign+FIXLENGTH(Decdeg,2)+separator+FIXLENGTH(Decminute,2)+separator+strSecond
   
   ENDELSE



   RETURN, strOut

END
