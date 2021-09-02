; Converts a Decimal RA into the standard format used in tables:
; e.g. HH MM SS.S

FUNCTION StandardRA, DecimalRA, decimals, NOSPACE = nospace, $
                     SEPARATOR = separator, LATEX = latex, GRAPHIC=graphic
   IF N_PARAMS() EQ 1 THEN decimals=1

   RASeconds = DecimalRA*3600
   RoundedRA = DOUBLE(LONG(RASeconds*(10^decimals) + 0.5)) / (10^decimals)

   ResetInd = WHERE(RoundedRA GE LONG(24)*3600)  
   IF ResetInd(0) GE 0 THEN RoundedRA(ResetInd) = RoundedRA(ResetInd)-(LONG(24)*3600)

   RAhour = FIX(RoundedRA/3600)
   RAminute = FIX((RoundedRA - LONG(RAhour)*3600)/60)
   RAsecond = FIX(RoundedRA - LONG(RAhour)*3600 -LONG(RAminute)*60)

   RAdecimalsec = FIX( (RoundedRA - LONG(RAhour)*3600 - LONG(RAminute)*60 - LONG(RAsecond))*10^decimals)
   
   strSecond = FIXLENGTH(RAsecond,2)
   IF decimals GT 0 THEN BEGIN
       strSecond=strSecond+"."+FIXLENGTH(RAdecimalsec,decimals)
   ENDIF

   IF KEYWORD_SET(nospace) THEN separator = "" ELSE BEGIN
       IF NOT KEYWORD_SET(separator) THEN separator = " "
   ENDELSE
      
   IF KEYWORD_SET(latex) THEN BEGIN
       strOut = FIXLENGTH(RAhour,2)+"$^h$"+FIXLENGTH(RAminute,2)+"$^m$"+strSecond+"$^s$"
   ENDIF ELSE IF KEYWORD_SET(graphic) THEN BEGIN
       strOut = FIXLENGTH(RAhour,2)+"!Uh!N"+FIXLENGTH(RAminute,2)+"!Um!N"+strSecond+"!Us!N"       
   ENDIF ELSE BEGIN      
       strOut = FIXLENGTH(RAhour,2)+separator+FIXLENGTH(RAminute,2)+separator+strSecond
   ENDELSE

   RETURN, strOut

END
