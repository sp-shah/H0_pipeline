; the goal of this script is to try to obtain the value 
; that LIGO obtained in their paper


Pro compute_vel 
  
  cmb_vel = 369.
  hvel = [2954., 2948., 3299., 2978., 2903.]
  dist = [40.10, 40.08, 44.59, 40.43, 39.57]
  ; either
  hvel = dist*73.
  ; or
  hvel = hvel + cmb_vel
  
  kmag = [9.64, 9.75, 9.12, 9.30, 9.29]
  absmag = kmag - 25. - 5.*ALOG(dist)
  weighted_hvel = hvel/absmag
  norm = total(1./absmag)
  ; either
  result = total(weighted_hvel)/norm
  result = mean(hvel)
  ; or
  print, result

end
