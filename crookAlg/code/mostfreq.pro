PRO test
  
  FOR i=0, 3 Do BEGIN
     print, i
  ENDFOR

END

FUNCTION mostfreq, ar

  count = FLTARR(max(ar)+1)

  FOR i=0, max(ar) DO BEGIN

     w = where(ar eq i)
     count(i) = N_ELEMENTS(w)

  ENDFOR
  
  return, count

END


