FUNCTION Outcome, Expression, IfTrue, IfFalse
   ; If turns IfTrue if expression is true, otherwise returns IfFalse

   Result = REPLICATE(IfFalse, N_ELEMENTS(Expression))
   indTrue = WHERE(Expression, COMPLEMENT = indFalse)
   IF indTrue(0) GE 0 THEN Result(indTrue) = IfTrue(indTrue)
   RETURN, Result
END
