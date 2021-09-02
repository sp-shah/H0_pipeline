; Takes a number, rounds it, replaces +/- with p/n, returns a string

FUNCTION PNString, Num, FIXLENGTH=FixLen
   NumR = ROUND(Num)
   IF NumR LT 0 THEN SignStr = "n" ELSE SignStr = "p"

   IF N_ELEMENTS(FixLength) GT 0 THEN strNum = FixLength(ABS(NumR), FixLen) $
   ELSE strNum = STRTRIM(ABS(NumR),2)

   RETURN, SignStr+strNum
END
