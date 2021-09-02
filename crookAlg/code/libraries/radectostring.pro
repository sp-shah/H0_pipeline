; Takes decimal RA, Dec (hrs, deg) and converts to string HHMMSS+DDMMSS
; Length is 13 for normal, or 66 for latex

FUNCTION DecimalToHMS, Decimal, LATEX=latex, RA=texRA
   ; require +ve decimal
   h = FLOOR(Decimal)
   m = FLOOR((Decimal-h)*60)
   s = ROUND((Decimal-h)*3600 - m*60)
   
   hstr = FixLength(h,2)
   mstr = FixLength(m,2)
   sstr = FixLength(s,2)

   IF KEYWORD_SET(latex) THEN BEGIN
       IF KEYWORD_SET(texRA) THEN $
         str = hstr+"$^\mathrm{h}$"+mstr+"$^\mathrm{m}$"+sstr+"$^\mathrm{s}$" $
       ELSE str = hstr+"$^\circ$"+mstr+"'"+sstr+"''"
   ENDIF ELSE BEGIN
       str = hstr+mstr+sstr
   ENDELSE

   RETURN, str

END

FUNCTION RADecToString, RA, Dec, LATEX=latex
   IF Dec GE 0 THEN Sign = "+" ELSE Sign = "-"

   IF KEYWORD_SET(latex) THEN $
     str = DecimaltoHMS(RA, /LATEX, /RA)+" & "+Sign+DecimaltoHMS(ABS(Dec), /LATEX) $
   ELSE str = DecimaltoHMS(RA)+Sign+DecimaltoHMS(ABS(Dec))

   RETURN, str
END
