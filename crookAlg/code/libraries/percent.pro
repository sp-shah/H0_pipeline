FUNCTION Percent, Fraction
   ; Returns a percentage as a string with %-sign appended

   RETURN, STRING(STRING(Fraction * 100, FORMAT="(F4.1)"),"%")

END
