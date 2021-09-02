PRO checkstrays, groupid, cat_groupid, cat_ra, cat_dec, cat_hvel, cat_dis, cat_kmag
  
  ;collect the indices of all the strays
  w = where(groupid eq 0)
  print, n_elements(w)
  print, cat_groupid(w)
  print, cat_ra(w)
  print, cat_dec(w)
  print, cat_hvel(w)
  print, cat_dis(w)
  print, cat_kmag(w)
 
  

  
end
