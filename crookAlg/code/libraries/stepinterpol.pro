; Evaluates graph 2 at abscissa of graph 1
; assuming the function (of graph 2) is step-like
; i.e. they take constant values and jump at each entry.

FUNCTION StepInterpol, V, X, U
  ; Returns V, evaluated at points U
  ; Requires X and U to be sorted in numerical order

  yOut = FLTARR(N_ELEMENTS(U))
  FOR i = 0, N_ELEMENTS(U)-1 DO BEGIN
      indBelow = WHERE(X LE U(i))
      IF indBelow(0) GE 0 THEN yOut(i) = V(indBelow(N_ELEMENTS(indBelow)-1)) $
        ELSE yOut(i) = 0
  ENDFOR

  RETURN, yOut

END
