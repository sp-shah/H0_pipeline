PRO groupstats, groupid, cat_groupid
  ;print, N_ELEMENTS(cat_groupid)
  ;index of the array groupPOP refers to the group number
  ;the value of the element refers to the number of galaxies
  ;in the group
  POP = mostfreq(groupid) ; includes the number of singles 
  nsingles = POP(0)
  print, "Number of singles"
  print, nsingles
  groupPOP = POP(1:*)
  print, "Max number of members in group"
  print, max(groupPOP)

  wbinaries = where(groupPOP eq 2)
  remove, wbinaries, groupPOP

  w3 = where(groupPOP GE 3)
  print, "more than 3 membership"
  print, n_elements(w3)

  w10 = where(groupPOP GE 10)
  ;print, w10 
  print, "more than 10 mem"
  print, n_elements(w10)

  w50 = where(groupPOP GE 50)
  print, "More than 50 mem"
  print, n_elements(w50)


  ;wtest = where(groupPOP eq 1)
  ;remove, wtest, groupPOP ; CHECK this why are there "groups" with 1 member

  print, mean(groupPOP)
  print, stddev(groupPOP)
  ;obtaining the population statistics of only the groups
  cat_groupPOP = mostfreq(cat_groupid)
  plothist, cat_groupPOP, ylog = 1,  color = "black", /halfbin,  /xlog,xtitle = "Group Membership", ytitle = "Number of Groups", xrange = [1,300]
  plothist, groupPOP, ylog = 1, color = "red", /halfbin, /xlog, /overplot


  
  
end
