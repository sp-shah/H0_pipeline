;Created by Shivani Shah to run the crook algorithm on simulation data
;and get the desired output

Function read_file, filename 
  ;readcol, filename, Num, Name, RAh, RAm, RAs, DE, DEd, DEm, DEs, HVel, Kmag, Dis, Corr, FORMAT = 'I, A, I, I, I, A, I, I, I, I, F, F, I'
  ;readcol, filename, odd, even
  data = read_ascii(filename, TEMPLATE = ASCII_TEMPLATE(filename))
  return, data
END



PRO run_percolation_simdata

  filename = "../data/crook_groups.txt"
  data = read_file(filename)
  print, "data received"
  print, "printed received data"
  num = data.(0)
  ;dict = dictionary(keys, va

  path_simbox = "../data/1600/run2_linkinglengths/0p3mps/periodic_box_wvelcorr85.hdf5"
  ;path_simbox = "../data/periodic_box_wvelcorr.hdf5"
  file_id = H5F_OPEN(path_simbox)
  hvel_id = H5D_OPEN(file_id, "sim1/GalHvel")
  ;hvel_id = H5D_OPEN(file_id, "sim1/hvel")
  hvel = H5D_READ(hvel_id)

  ;recvel_id =  H5D_OPEN(file_id, "sim1/rec_vel_periodic")
  ;recvel = H5D_READ(recvel_id)

  dist_id =  H5D_OPEN(file_id, "sim1/distEst")
  dist = H5D_READ(dist_id)

  ra_id =  H5D_OPEN(file_id, "sim1/GalRArad")
  ;ra_id =  H5D_OPEN(file_id, "sim1/ra")
  raRAD = H5D_READ(ra_id)

  dec_id =  H5D_OPEN(file_id, "sim1/GalDECrad")
  ;dec_id =  H5D_OPEN(file_id, "sim1/dec")
  decRAD = H5D_READ(dec_id)

  SubhaloMass_id = H5D_OPEN(file_id, "sim1/SubhaloMass")
  SubhaloMass = H5D_READ(SubhaloMass_id)
  ;print, SubhaloMass

  HaloInd_id = H5D_OPEN(file_id, "sim1/HaloInd")
  HaloInd = H5D_READ(HaloInd_id)

  GalAbsMag_id = H5D_OPEN(file_id, "sim1/GalAbsMag")
  GalAbsMag = H5D_READ(GalAbsMag_id)

  ;HaloMass_id = H5D_OPEN(file_id, "HaloMass")
  ;HaloMass = H5D_READ(HaloMass_id)

  ;HaloId_id = H5D_OPEN(file_id, )
  
  radtodeg = 180./!PI
  ra = raRAD*radtodeg/15. ; convert to hours
  dec = decRAD*radtodeg

  H0 = 73.
  D0 = [0.56]
  V0 = [350.]
  magLimit = 11.25
  ;dist = hvel/H0
  
  H5F_CLOSE, file_Id

  ;plot, recvel

  
  print, "starting for loop"
  for d=0L, n_elements(D0)-1 do begin
     D = D0[d]
     print, D
     for v = 0L, n_elements(V0)-1 do begin
        V = V0[v]
        print, V
        x = percolation(ra, dec, hvel, magLimit, D, V, QUIET = 1, H0= H0, renumber = 1, GALDIST = dist)
        print, "percoation done"
        unwanted = dist_cutoff(x, dist)
        print, "dist cut off done"
        xthisloop = x
        remove, unwanted, xthisloop
        ;print, "removed from xthisloop"
        ;print, xthisloop
        remove, unwanted, ra
        print, "removed from ra"
        remove, unwanted, dec 
        print, "removed from dec"
        remove, unwanted, dist 
        print, "removed from dist"
        remove, unwanted, hvel
        print, "removed from hvel"
        remove, unwanted, SubhaloMass
        remove, unwanted, HaloInd
        remove, unwanted, GalAbsMag
        print, "starting groupstats"
        ;in groupstats the single galaxies are 
        ; not removed correctly
        groupstats, xthisloop, num
         
      endfor
  endfor
  print, "for loop done"
  print, "check"
  ;print, decRAD
  groupMem = mostfreq(xthisloop) 
  groupId = xthisloop
  writePath = "sim1/"
  filename = "../data/1600/run1/groupedGal85.hdf5"
  ;filename = "../data/1600/run2_linkinglengths/0p3mps/periodic_box_wvelcorr.hdf5"
  fid =  H5F_CREATE(filename)
  values = list(hvel, dist, groupMem, raRAD, decRAD, groupId, SubhaloMass, HaloInd, GalAbsMag)
  keys = ["GalHvel", "distEst", "groupMem", "GalRArad", "GalDECrad", $
                "groupId", "SubhaloMass", "HaloInd", "GalAbsMag"]
  ;values = list(groupMem, groupID)
  ;keys = ["groupMem", "groupID"]
  dict = dictionary(keys, values)

  for j=0L, N_ELEMENTS(keys)-1 do begin
     datatypeID = H5T_IDL_CREATE(dict[keys(j)])
     dataspaceID = H5S_CREATE_SIMPLE(size(dict[keys(j)], /DIMENSIONS))
     datasetID = H5D_CREATE(fid, keys(j), datatypeID, dataspaceID)
     H5D_WRITE, datasetID, dict[keys(j)]
     H5D_CLOSE, datasetID
     H5S_CLOSE, dataspaceID
     H5T_CLOSE, datatypeID
  endfor
  H5F_CLOSE, fid
  

  ;; distTypeId = H5T_IDL_CREATE(dist)
  ;; distSpaceId = H5S_CREATE_SIMPLE(size(dist, /DIMENSIONS))
  ;; dist_id = H5D_CREATE(fid, "dist", distTypeId, distSpaceId)
  ;; H5D_WRITE, dist_id, dist
  
  ;; groupMemTypeId = H5T_IDL_CREATE(groupMem)
  ;; groupMemSpaceId = H5S_CREATE_SIMPLE(size(groupMem, /DIMENSIONS))
  ;; groupMem_id = H5D_CREATE(fid, "groupMem", groupMemTypeId, groupMemSpaceId)
  ;; H5D_WRITE, groupMem_id, groupMem

  ;; raRADTypeId = H5T_IDL_CREATE(raRAD)
  ;; raRADSpaceId = H5S_CREATE_SIMPLE(size(raRAD, /DIMENSIONS))
  ;; raRAD_id = H5D_CREATE(fid, "raRAD", raRADTypeId, raRADSpaceId)
  ;; H5D_WRITE, raRAD_id, raRAD
  
  ;; groupIdTypeId = H5T_IDL_CREATE(groupId)
  ;; groupIdSpaceId = H5S_CREATE_SIMPLE(size(groupId, /DIMENSIONS))
  ;; groupId_id = H5D_CREATE(fid, "groupId", groupIdTypeId, groupIdSpaceId)
  ;; H5D_WRITE, groupId_id, groupId

  ;; decRADTypeId = H5T_IDL_CREATE(decRAD)
  ;; decRADSpaceId = H5S_CREATE_SIMPLE(size(decRAD, /DIMENSIONS))
  ;; decRAD_id = H5D_CREATE(fid, "decRAD", decRADTypeId, decRADSpaceId)
  ;; H5D_WRITE, decRAD_id, decRAD

  ;; H5_PUTDATA, filename, "sim1/hvel", hvel
  ;; H5_PUTDATA, filename, "sim1/dist", dist
  ;; H5_PUTDATA, filename, "sim1/groupID", xthisloop
  ;; H5_PUTDATA, filename, "sim1/raRAD", raRAD
  ;; H5_PUTDATA, filename, "sim1/decRAD", decRAD
  ;; H5_PUTDATA, filename, "sim1/groupMem", groupMem
  ;; H5_PUTDATA, filename, "sim1/SubhaloMass", SubhaloMass
  print, "what"
end



PRO run_perc_2mrs 
  ;; test = "../data/idl_test.hdf5"
  ;; file_id = H5F_OPEN(test)
  
  ;; dataset2_id = H5D_OPEN(file_id, "data/dataset2")
  ;; dataset2 = H5D_READ(dataset2_id)
  ;; print, dataset2

  
  ;; f = "../data/crook_groups.txt"
  ;; d = read_file(f)
  ;; num = d.(0)
  ;; name = d.(1)
  ;; dist_catalog = d.
  ;; w720  = where(num eq 720)
  ;; compare_twomrsid = name(w720)
  ;; ;print, compare_twomrsid


  ; twomrs_final consists of the simulated galaxies 
  ; plus the vel field correctiond one by me
  twomrs_final = "../data/2mrs_final.hdf5"
  file_id =  H5F_OPEN(twomrs_final)

  recvel_full_id = H5D_OPEN(file_id, "data/recvel_full")
  recvel_full = H5D_READ(recvel_full_id)
  

  ra_full_id = H5D_OPEN(file_id, "data/ra_full")
  ra_full = H5D_READ(ra_full_id)

  dec_full_id = H5D_OPEN(file_id, "data/dec_full")
  dec_full = H5D_READ(dec_full_id)
  
  twomrsid_full_id = H5D_OPEN(file_id, "data/twomrsid_full")
  twomrsid_full = H5D_READ(twomrsid_full_id)
  
  dist_full_id = H5D_OPEN(file_id, "data/dist_full")
  dist_full = H5D_READ(dist_full_id)
  
  recvel_corr_full_id = H5D_OPEN(file_id, "data/recvel_corr_full")
  recvel_corr_full = H5D_READ(recvel_corr_full_id)

  ;; h5f_close, file_id
  ;; h5d_close, ra_full_id
  ;; h5d_close, dec_full_id
  ;; h5d_close, twomrsid_full_id
  ;; h5d_close, dist_full_id
  ;; h5d_close, recvel_full_id
  ;; h5d_close, recvel_corr_full_id
  
  ra_full = ra_full/15. ;converting ra degrees to hours


  magLimit = 11.25
  D0 = 0.56
  ; percentage of fiducial D0
  ;D0_array = make_array(start = 0.2, increment = 0.1, /index, /float, size = size(findgen(1,18))) 
  ;D0_array = D0_array*0.56/100.
  ; percentage of fiducial V0
  ;V0_array = make_array(start = 150., increment = 10, /index, /float, size = size(findgen(1, 35)))
  ;V0_array = V0_array*350./100.
  V0 = 350.
  ;D0_array = make_array(start = D0 - 0.5*D0, increment = 0.1*D0, /index, /float, size = size(findgen(1, 5)))
  ;V0_array = make_array(start = V0 - 0.5*V0, increment = 0.1*V0, /index, /float, size = size(findgen(1, 5)))
  H0 = 73.
  nothers = make_array(180, 350)
  avgV = make_array(180, 350)
  ;filenamesAR =[ "../data/2MRS/groupMemM50.hdf5", "../data/2MRS/groupMeM40.hdf5", "../data/2MRS/groupMem30.hdf5", $
  ;                "../data/2MRS/groupMemM20.hdf5", "../data/2MRS/groupMemM10.hdf5"]

  D0_array = [D0*0.3 + D0]
  V0_array = [V0*0.3 + V0]
  filenamesAR = ["../data/2MRS/groupMem30.hdf5"]

  ; The following loop is structured so that there the 
  ; the parallel and perp linking length increase together
  ; by 10%
  
  for d=0L, n_elements(D0_array)-1 do begin
     D0 = D0_array(d)
     print, D0
     ;for v=0L, n_elements(V0_array)-1 do begin
     V0 = V0_array(d)
     print, V0, D0
     x = percolation(ra_full, dec_full, recvel_full, magLimit, D0, V0, QUIET = 1, H0= H0, renumber = 1, GALDIST = dist_full)
     unwanted = dist_cutoff(x, dist_full)
                                ;print, "Number of elements in x"
        ;print, n_elements(x)
                                ;checkstrays,x, num, radeg, decdeg,
                                ;hvel, dis, kmag
     xthisloop = x
     twomrsid_thisloop = twomrsid_full
     hvel_thisloop = recvel_full
     remove, unwanted, xthisloop
     remove, unwanted, twomrsid_thisloop
     remove, unwanted, hvel_thisloop
     
        ;;                         ;obtaining the target id in a way that can be used to parse 
        ;; targetid = strcompress(string(13094770))
        ;; last = strtrim(string(-2323017), 2)
        ;; targetid = strcompress(targetid + last)
        ;; targetid = strtrim(targetid, 2)

        ;;                         ;obtain the groupid of 4993
        ;; targetIndex = where(twomrsid_thisloop eq targetid)
        ;; targetGroupid = xthisloop(targetIndex(0))
        ;; ; obtain other members
        ;; if targetGroupid eq 0 then begin 
        ;;    nothers(d,v) = 0.
        ;;    avgV(d, v) = hvel_thisloop(targetIndex(0))
        ;; endif else begin  
        ;;    wothers = where(xthisloop eq targetGroupid)
        ;;    nothers(d,v) = n_elements(wothers)
        ;;    avgV = mean(hvel_thisloop(wothers))
        ;; endelse 
        ;;                         ;print, n_elements(wothers)
        ;;                         ;print, "others members"

     ; Write the new group catalog to file
     groupMem = mostfreq(xthisloop) 
     ;groupId = xthisloop     
     fid =  H5F_CREATE(filenamesAR(d))
     datatypeID = H5T_IDL_CREATE(groupMem)
     dataspaceID = H5S_CREATE_SIMPLE(size(groupMem, /DIMENSIONS))
     datasetID = H5D_CREATE(fid, "groupMem", datatypeID, dataspaceID)
     H5D_WRITE, datasetID, groupMem
     H5D_CLOSE, datasetID
     H5S_CLOSE, dataspaceID
     H5T_CLOSE, datatypeID
     H5F_CLOSE, fid
     

  endfor 
 
 

  

  ;print, n_elements(D0_array)
  ; write the resulting data to a file 
  ;write_csv, "nothers.csv", nothers
  ;write_csv, "avgV.csv", avgV
  ;H5_PUTDATA, "ll.h5", "nothers", nothers
  ;H5_PUTDATA, "ll.h5", "avgV", avgV
  ;H5_PUTDATA, "ll.h5", "V0_array", V0_array
  ;H5_PUTDATA, "ll.h5", "D0_array", D0_array
  ;write_scv, "linking_lengths.csv", D0_array, V0_array



     ;; print, "Number of elements in unwanted"
     ;; print, n_elements(unwanted)
     ;; remove, unwanted, x
     ;; remove, unwanted, twomrsid_full
     ;; print, "Number of groups"
     ;; print, max(x)
     ;; count = mostfreq(x)                
     ;; w = where(count eq max(count(1:*)))
     ;; print, "Maximum number of members or singles"
     ;; print, count(0)
     ;; print, "Maximum numebr of members in a group"
     ;; print, count(w)
     ;; print, "Where the maximum count is occuring corresponding to the group number"
     ;; print, w
     ;; wx = where(x eq w[0])
     
     ;; groupstats, x

  ;; ; check for the overlap of virgo galaxies in the published
  ;; ; catalog and the one created right now
  

  ;; virgo_twomrsid = twomrsid_full(wx)
  ;; virgo_dist = dist_full(wx)
  ;; virgo_recvel = recvel_full(wx)
  

  ;; ; compare the two arrays
 
  ;; for j=0L, n_elements(compare_twomrsid)-1 do begin
  ;;    string = compare_twomrsid[j]
  ;;    new_string = string.replace('.', '')
  ;;    compare_twomrsid[j] = new_string
  ;;  endfor
 

  ;; extra = []
  ;; for k=0L, n_elements(virgo_twomrsid)-1 do begin
  
  ;;    id = virgo_twomrsid(k)
  ;;    boolean = strcmp(id, compare_twomrsid)
  ;;    w = where(boolean eq 1)
     
  ;;    if (w(0) eq -1) then begin
  ;;       extra = [extra, id]
  ;;    endif 
  ;; endfor
  
  ;; print, extra
  ;; print, n_elements(extra)
  ;; ;print, compare_twomrsid(0)
  ;; ;print, virgo_twomrsid(0)


  ; ;check of NGC 4993

  
  targetid = strcompress(string(13094770))
  last = strtrim(string(-2323017), 2)
  targetid = strcompress(targetid + last)
  targetid = strtrim(targetid, 2)
  print, targetid

  targetIndex = where(twomrsid_full eq targetid)
  targetGroupid = x(targetIndex(0))
  print, targetGroupid
  wothers = where(x eq targetGroupid)
  print, n_elements(wothers)
  print, "others members"
  ;print, twomrsid_full(wothers)

end




Function dist_cutoff, x, distance
  
  print, "min and max"
  print, min(x)
  print, max(x)

  groupids = indgen(max(x)+1)
  ;removing the groupid 0, which is for singles
  remove, 0, groupids
  print, min(groupids)
  print, max(groupids)
  ; creating an empty array for indices 
  ; that will eventually be deleted
  unwanted = []
 
  
  ;excluding groupid 0 which corresponds to singles
  for j=0L, n_elements(groupids)-1 do begin
     ;print, j
     w_groupmembers = where(x eq groupids(j))
     ;if n_elements(w_groupmembers) eq 2 then continue
     groupdist = mean(distance(w_groupmembers))
     if (groupdist gt 140.) then begin
        ;print, "yes"
        unwanted = [unwanted, w_groupmembers]
     endif 
    
  endfor

  return, unwanted

end 



PRO run_percolation

filename = "../data/crook_groups.txt"
data = read_file(filename)
print, "data received"
print, "printed received data"
num = data.(0)
name = data.(1)
rah = float(data.(2))
ram = float(data.(3))
ras = float(data.(4))
decd = STRING(data.(5))
decm = float(data.(6))
decs = float(data.(7))
hvel = FLOAT(data.(8))
kmag = data.(9)
dis = float(data.(10))
print, "obtained all data"
radeg = (rah + ram/60. + ras/3600.) ;actually in hours
decsign = STRARR(N_ELEMENTS(decd))
decdeg = FLTARR(N_ELEMENTS(decd))
dec = FLTARR(N_ELEMENTS(decd))

; obtaining the declination in degree by taking care of sign
FOR i = 0L, N_ELEMENTS(decd)-1L DO BEGIN
   decsign(i) = strmid(decd(i), 0, 1)
   dec(i) = float(strmid(decd(i), 1, 2))
   IF decsign(i) eq "-" THEN BEGIN
      ;decsign(i) = -1.
                                ; take out the negative from decd
                                ; first and then apply negative to
                                ; decm and decs
      ;decdeg(i) = decsign(i)*(decsign(i)*decd(i) + decm(i)/60. + decs(i)/3600.) 
      decdeg(i) = -((dec(i)) + decm(i)/60. + decs(i)/3600.)
      ;; print, decd(i)
      ;; print, decdeg(i)
      ;; print, "--------------"
   ENDIF ELSE BEGIN 
      ;decsign(i) = 1.
      decdeg(i) = decd(i) + decm(i)/60. + decs(i)/3600.
      
   ENDELSE
ENDFOR


;; w213 = where(num eq 213)
;; print, w213
;; print, radeg(w213)
;; print, decdeg(w213)
;; print, hvel(w213)
;; print, dis(w213)

; a subset of the galaxies to perform the check
;; radeg5 = radeg(16:18)
;; decdeg5 = decdeg(16:18)
;; hvel5 = hvel(16:18)
;; dis5 = dis(16:18)
;; num5 = num(16:18)
;; print, "Group 5"
;; print, decdeg5

;defining other quantities 
magLimit = 11.25
D0 = 0.56
V0 = 350.
H0 = 73.
x = percolation(radeg, decdeg, hvel, magLimit, D0, V0, QUIET = 1, H0= H0, renumber = 1, GALDIST = dis)
print, "Number of groups"
print, max(x)
count = mostfreq(x)
;print, count
w = where(count eq max(count(1:*)))
print, "Maximum number of members or singles"
print, count(0)
print, "Maximum numebr of members in a group"
print, count(w)
print, "Where the maximum count is occuring corresponding to the group number"
print, w
wx = where(x eq w[0])
print, num(wx)
groupstats, x, num
;checkstrays,x, num, radeg, decdeg, hvel, dis, kmag
END
