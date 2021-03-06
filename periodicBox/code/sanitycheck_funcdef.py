import numpy as np
import matplotlib.pyplot as plt 
import val_sanitycheck as val
from mpl_toolkits import mplot3d
import sys
from collections import Counter
import h5py
import funcdef as fd
import matplotlib.colors as mlc
import matplotlib as mpl
import hod_wrapper as hod_wrap
from astropy.io import ascii
import numpy.ma as ma
from scipy.spatial import KDTree
mpl.rcParams['agg.path.chunksize'] = 10000
from matplotlib import rc


rc('text', usetex=True) 
rc("text.latex", unicode = True)
rc("font", size =16., family = 'serif')




#path of two primary files: val.path_to_pergal_values and val.path_to_group_info
#fields in gal_values: ra, dec, l, b, pos_icrs, vel_icrs, rec_vel
#fieles in group_info = galaxy_grouped [boolean array specifying whether the
#the gal is grouped or not] and group_id [id to which the gal belongs] 


#def pick_groups_random():
    
    #this function definition picks groups on random
    

def extract_gal_data():
    
    
   
    file1 = h5py.File(val.path_to_group_info, "r")
    sim1_file1 = file1["sim1"]
    galaxy_grouped_bool = sim1_file1["galaxy_grouped"][:]
    group_id = sim1_file1["group_id"][:]


    file1.close()
    
    
    file2 = h5py.File(val.path_to_periodic_box, "r")
    sim1_file2 = file2["sim1"]
    ra = sim1_file2["ra_periodic"][:]
    dec = sim1_file2["dec_periodic"][:]
    pos_icrs = sim1_file2["pos_periodic"][:] 
    vel_icrs = sim1_file2["vel_periodic"][:]
    rec_vel = sim1_file2["rec_vel_periodic"][:]
    abs_mag = sim1_file2["abs_mag_periodic"][:]
    file2.close()


def array_processing():
    
    group_id = np.copy(val.group_id)
    #pick out the group ids of those galaxies that are grouped
    group_id_rel = group_id[group_id != -1] - 1
    #form an array of unique group ids
    group_id_uniq = np.sort(np.unique(group_id_rel))

    print(np.min(group_id_uniq))
    print(np.max(group_id_uniq))
    print(len(group_id_uniq))
    
    return group_id_rel, np.sort(group_id_uniq)
    
def ngals(group_id_rel, group_id_uniq):
    
    #Number of galaxies in each group
    
    ngals = np.zeros(len(group_id_uniq), dtype = np.int)
    for j in range(len(group_id_uniq)):
        ngals[j] = len(group_id_rel[group_id_rel == group_id_uniq[j]])
    
    return ngals


def hist_ngals(group_id_rel, group_id_uniq):

    #distribution of number of galaxies
    
    n_gals = ngals(group_id_rel, group_id_uniq)
    print(np.max(n_gals))
    print(np.min(n_gals))
    plt.figure()
    plt.hist(n_gals, bins=100)
    plt.xlabel("Number of Members")
    plt.ylabel("Number of Groups")
    plt.yscale("log")
    #plt.show()
    plt.savefig("../plots/ngals_hist.png")


def threed_spherical(group_id_rel, group_id_uniq):

    #--------------------------------------------------------
    #The goal of this function definition is to take in one 
    #or multiple groups and plot them in a 3D space of 
    #RA, DEC and recessional velocity 

    ra = val.ra
    dec = val.dec
    rec_vel = val.rec_vel
    
    #Number of galaxies in each group sorted by groupnumber
    n_gals = ngals(group_id_rel, group_id_uniq)
    
    print(np.max(n_gals))

    #collect the group_id of the most populated group
    most_pop_ind = np.where(n_gals == np.max(n_gals))[0]

    #create a boolean array specifying the galaxies that belong to this 
    #group
    resp_galind = [val.group_id == most_pop_ind]

    resp_ra = ra[resp_galind]
    resp_dec = dec[resp_galind]
    resp_recvel = rec_vel[resp_galind]
    print(len(resp_ra))
    print(len(resp_dec))
    print(len(resp_recvel))
    
    plt.figure()
    ax = plt.axes(projection = '3d')
    ax.scatter3D(resp_ra, resp_recvel, resp_dec)
    plt.show()



def intersect(x, y, z):
    xset = set(x); yset = set(y); zset = set(z)
    set1 = xset.intersection(yset)
    set2 = set1.intersection(zset)
    
    return np.array(list(set2))




def threed_subsection():

    #collecting the indices of the galaxies that are grouped
    galaxy_grouped_ind = np.where(val.galaxy_grouped_bool == True)[0]
    

    #print the range of ra, dec, rec_vel 
    ra = np.copy(val.ra); dec = np.copy(val.dec); rec_vel = np.copy(val.rec_vel)
    
    '''
    ra_all = ra[galaxy_grouped_ind]
    dec_all = dec[galaxy_grouped_ind]
    rec_vel_all = rec_vel[galaxy_grouped_ind]

    print(np.min(ra_all), np.max(ra_all))
    print(np.min(dec_all), np.max(ra_all))
    print(np.min(rec_vel_all), np.max(rec_vel_all))
    '''

    #picking a range
    ra_range = [-3.14, -2.04]
    dec_range = [-1.49, -0.39]
    recvel_range = [1488, 6000.]


    #pick out the galaxies that are in this range

    #indices that satisfy each of the conditions
    ra_ind_satisfy = np.sort(np.where((ra <= ra_range[1]) & (ra >= ra_range[0]))[0])
    dec_ind_satisfy = np.sort(np.where((dec <= dec_range[1]) & (dec >= dec_range[0]))[0])
    recvel_ind_satisfy = np.sort(np.where((rec_vel <= recvel_range[1]) & (rec_vel >= recvel_range[0]))[0])

    #obtain the indices that are common
    intersect_ind = intersect(ra_ind_satisfy, dec_ind_satisfy, recvel_ind_satisfy)

    #print(intersect_ind)
    #sys.exit()
    #obtain the unique gr numbers belonging to the galaxies at these indices
    group = val.group_id[intersect_ind]
    group_uniq = np.unique(group)

    print(len(group_uniq))

    #pick out all the galaxies that belong to these groups and plot
    
    fig = plt.figure()
    ax = fig.add_subplot(111, projection = '3d')
    ax.set_xlabel("RA [radians]")
    ax.set_ylabel("L.o.s recessional vel [km/s]")
    ax.set_zlabel("Dec [radians]")


    colors = ["red", "yellow", "orange", "black", "blue", "green", "grey", 
              "darkmagenta", "y", "pink","lightseagreen", "deeppink", "darkviolet", "maroon", "sienna", "palegreen", "dodgerblue", "lavender"]
    i = 0
    for grnr in group_uniq[1:]:
        gal_ind = np.where(val.group_id == grnr)[0]
        resp_ra = ra[gal_ind]; resp_dec = dec[gal_ind]; resp_recvel = rec_vel[gal_ind]
        
        ax.scatter(resp_ra, resp_recvel, resp_dec, c = colors[i])
        i += 1


    plt.show()


def cart2sphere(x, y, z, vx, vy, vz):


    #shift xyz positions
    #assume only one MW, which is in the center sim box
    x -= (370.)
    y -= (370.)
    z -= (30.)
    
    #rotate xyz positions
    phinot = (39.*np.pi/180.)
    x = np.cos(phinot)*x + np.sin(phinot)*y + 0*z
    y = -np.sin(phinot)*x + np.cos(phinot)*y + 0*z
    z = z

    
    #obtaining the distance to the galaxy [same in both the coordinate
    #systems since the origin hasn't changed]
    d = np.sqrt(x**2 + y**2 + z**2) #[Mpc/h]

    #ra, dec in icrs coordinates
    ra = np.arctan2(y,x)  #RA in radians [-pi,pi]
    dec = np.arcsin(z/d)   #Declination in radians [-pi/2, pi/2]

    #Hubble velocity 
    vh = 100. * d

    #los peculiar velocity 
    vpec_los = (vx*x + vy*y + vz*z)/d #same for both the coordinate systems since the origin doesn't change
    
    #total los recessional vel 
    c = 2.98e5
    zh = vh/c 
    zpec = vpec_los/c #change this to full form?
    ztotal = ((1+zh)*(1+zpec)) - 1
    vtotal_los = ztotal*c #change this to full form?

    return ra,dec, vtotal_los, x, y, z

def turnintoarray(a):
    if np.isscalar(a[0]):
        return np.array([a])
    ar = []
    for l in a:
        ar_list = []
        for ele in l:
            ar_list.append(ele)
        ar.append(ar_list)
    return np.array(ar)






def massive_halos():
    

    #sorting the halos in ascending order by mass and population
    groupmass = np.copy(val.groupmass)
    groupnsubs = np.copy(val.groupnsubs)
    mass_arg = np.argsort(groupmass)
    n_arg = np.argsort(groupnsubs)

    #sorting all the sim arrays according to mass argument
    grouppos = np.copy(val.grouppos[n_arg])
    #groupnsubs = np.copy(val.groupnsubs[mass_arg])
    #shift the cartesian grouppos to the 
    groupvel = np.copy(val.groupvel[n_arg])

    #collecting the position of the most massive/populated halos
    grouppos_massive = grouppos[-5:]
    groupvel_massive = groupvel[-5:]
    x = grouppos_massive[:,0]; y = grouppos_massive[:,1]; z = grouppos_massive[:,2]
    vx = groupvel_massive[:,0]; vy = groupvel_massive[:,1]; vz = groupvel_massive[:,2]

    #shifting the pos of halo to ra, dec, rec_vel 
    halo_ra, halo_dec, halo_rec_vel = cart2sphere(x, y, z, vx, vy, vz)

    #collecting group id of the most populated groups
    group_id_only = np.copy(val.group_id[val.group_id != - 1])
    freq = Counter(group_id_only)
    ind_most_freq = freq.most_common(5)
    ind_most_freq = turnintoarray(ind_most_freq)
    ind_most_freq = ind_most_freq[:,0]

    #collecting the galaxy quantities
    group_id = np.copy(val.group_id)
    galra = np.copy(val.ra); galdec = np.copy(val.dec); galrec_vel = np.copy(val.rec_vel)
    
    #collecting all the position coordinates of the galaxies that belong to the most 
    #populated groups

    galra_freq = []; galdec_freq = []; galrec_vel_freq = []
    for ii in ind_most_freq:
        match_bool = np.array(group_id == ii)
        galra_freq.extend(galra[match_bool])
        galdec_freq.extend(galdec[match_bool])
        galrec_vel_freq.extend(galrec_vel[match_bool])
        

    #galrec_vel_freq = np.reshape(galrec_vel_freq, (-1))
    #galra_freq = np.reshape(galra_freq, (-1))
    #galdec_freq = np.reshape(galdec_freq, (-1))


    #boolean array of where the group_id matches the most frequent
    #match_bool = group_id == ind_most_freq
    #galra_freq = galra[match_bool]; galdec_freq = galdec[match_bool]; 
    #galrec_vel_freq = galrec_vel[match_bool]
    

    #PLOTTING IT!!!!
    fig = plt.figure()
    ax = fig.add_subplot(111, projection = '3d')
    ax.set_xlabel("RA [radians]")
    ax.set_zlabel("L.o.s recessional vel [km/s]")
    ax.set_ylabel("Dec [radians]")
    

    ax.scatter(galra_freq, galdec_freq, galrec_vel_freq, c = 'black')
    ax.scatter(halo_ra, halo_dec, halo_rec_vel, c = 'red')

    plt.show()


def gal_ofpophalo():
    
    #This function definition will plot galaxies/groups/subhalos around the most populated halos 
    #if any are present
    
    #sorting the halos in ascending order by mass and population
    groupmass = np.copy(val.groupmass)
    groupnsubs = np.copy(val.groupnsubs)
    mass_arg = np.argsort(groupmass)
    n_arg = np.argsort(groupnsubs)

    #sorting all the sim arrays according to mass/population argument
    grouppos = np.copy(val.grouppos[n_arg])
    groupvel = np.copy(val.groupvel[n_arg])
    groupnsubs = groupnsubs[n_arg]

    #collecting the position of the 5 most massive/populated halos
    grouppos_massive = grouppos[-5:]
    groupvel_massive = groupvel[-5:]
    x = grouppos_massive[:,0]; y = grouppos_massive[:,1]; z = grouppos_massive[:,2]
    vx = groupvel_massive[:,0]; vy = groupvel_massive[:,1]; vz = groupvel_massive[:,2]

    #shifting the pos of halo to ra, dec, rec_vel 
    halo_ra, halo_dec, halo_rec_vel, x,y,z = cart2sphere(x, y, z, vx, vy, vz)

    #collecting the halo id of these 5 most populated halos 
    #halo id corresponds to the halo index
    haloid_pop = n_arg[-5:]
    
    #look for galaxies that have halo_id equal to the above, obtain their
    #group ids
    halo_id = np.copy(val.halo_ind)[:len(val.halo_ind)/27]
    group_id = np.copy(val.group_id)
    groupid = [] #represents the groups belonging to the corresponding halos
    galid = [] #represents the galaxies belonging to the correspondin halos
    for ii in haloid_pop:
        #collect the galaxies indices which belong to this halo
        gal_ind_cor_halo_ind = np.where(halo_id == ii)[0]
        print(len(gal_ind_cor_halo_ind))
        #collect group ids of the galaxies that belong to this halo
        group_id_cor_gal = group_id[gal_ind_cor_halo_ind]
        groupid.extend(group_id_cor_gal)
        galid.extend(gal_ind_cor_halo_ind)


    groupid = np.unique(groupid)
    groupid = groupid[groupid != -1]
    
    ################################################################33
    '''
    #Subhalo everything
    ##repeat the above for the subhalos belonging to the halos 
    subid = []
    subgrnr = np.copy(val.subgrnr) #gives the halo id to which the subhalo belongs
    for ii in haloid_pop:
        #collect the subhalos that belong to this halo 
        sub_ind_cor_halo_ind = np.where(subgrnr == ii)[0]
        subid.extend(sub_ind_cor_halo_ind)
    
    #collect the positions of the subhalo 
    subpos = np.copy(val.subpos)[subid]
    subvel = np.copy(val.subvel)[subid]
    subx = subpos[:,0]; suby = subpos[:,1]; subz = subpos[:,2]
    subvx = subvel[:,0]; subvy = subvel[:,1]; subvz = subvel[:,2]
    subra, subdec, sub_recvel, subx, suby, subz = cart2sphere(subx, suby, subz, subvx, subvy, subvz)
    '''
    ######################################################################
    '''
    #collect all the galaxies that belong to these groups and plot them 
    #with a color code
    fig = plt.figure()
    ax = fig.add_subplot(111, projection = '3d')
    #ax.set_xlabel("X [Mpc]")
    #ax.set_zlabel("Z [Mpc]")
    #ax.set_ylabel("Y [Mpc]")
    
    #-------------------------------------------
    #axis labels for spherical plot
    xloc = [-3., -2., -1., 0., 1., 2., 3.]
    xlab = [np.str(np.int(xl*180./np.pi)) for xl in xloc]
    ax.set_xticks(xloc)
    ax.set_xticklabels(xlab)
    ax.set_xlabel("RA [degrees]")

    zloc = [ 1.0, 1.10, 1.20, 1.30]
    ax.set_zticks(zloc)
    zlab = [np.str(np.int(zl*180./np.pi)) for zl in zloc]
    ax.set_zticklabels(zlab)
    ax.set_zlabel("Dec [degrees]")
    
    ax.set_ylabel("RecVel [km/s]")
    #------------------------------------------------

    gal_ra = np.copy(val.ra); gal_dec = np.copy(val.dec); gal_recvel = np.copy(val.rec_vel)
    gal_ra = gal_ra[galid]
    gal_dec = gal_dec[galid]
    gal_recvel = gal_recvel[galid]
    gal_pos = np.copy(val.pos_icrs)
    galx = gal_pos[:,0][galid]; galy = gal_pos[:,1][galid]; galz = gal_pos[:,2][galid]
    ax.scatter(gal_ra, gal_recvel, gal_dec, s = 1., alpha = 0.1)
    ax.scatter(halo_ra, halo_rec_vel, halo_dec, c = 'red', s = 20., marker = '*')
    #ax.scatter(subra, subdec, sub_recvel, s = 5., alpha = 0.1, color = 'green')
    #ax.scatter(subx, suby, subz, s = 1., alpha = 0.1, color = 'green')
    #ax.scatter(galx, galy, galz, s = 1., alpha = 0.1)
    #ax.scatter(x, y, z, s = 20., marker = '*')
    
    plt.show()
    plt.savefig("../plots/test1_sphere.png")
    sys.exit()
    '''
    ##########################################################################3
    #collect all the groups associated with these halos and plot them

    fig = plt.figure()
    ax = fig.add_subplot(111, projection = '3d')

    i = 0
    colors = ["orange", "green", "red", "magenta", "skyblue"]
    for gid in groupid:
        gal_arg = []
        gal_arg.extend(np.where(group_id == gid)[0])
        print(np.size(gal_arg))
        #collect the properties of these galaxies to plot
        gal_ra = np.copy(val.ra); gal_dec = np.copy(val.dec); gal_recvel = np.copy(val.rec_vel)
        gal_ra = gal_ra[gal_arg]
        gal_dec = gal_dec[gal_arg]
        gal_recvel = gal_recvel[gal_arg]

        ax.scatter(gal_ra, gal_recvel, gal_dec, c = colors[i], s = 5., alpha = 0.03)
        i += 1

     #axis labels for spherical plot
    xloc = [-3., -2., -1., 0., 1., 2., 3.]
    xlab = [np.str(np.int(xl*180./np.pi)) for xl in xloc]
    ax.set_xticks(xloc)
    ax.set_xticklabels(xlab)
    ax.set_xlabel("RA [degrees]")

    zloc = [ 1.0, 1.10, 1.20, 1.30]
    ax.set_zticks(zloc)
    zlab = [np.str(np.int(zl*180./np.pi)) for zl in zloc]
    ax.set_zticklabels(zlab)
    ax.set_zlabel("Dec [degrees]")
    
    ax.set_ylabel("RecVel [km/s]")
    #print(np.shape(gal_ra))
    #print(np.shape(gal_dec))
    #print(np.shape(gal_recvel))

    #plotting
   
    

   
    ax.scatter(halo_ra, halo_rec_vel, halo_dec, c = 'black', s = 20., marker = '*')
    
    plt.savefig("../plots/test2_sphere.png")
    plt.show()
    


#def crook_massfunc():
    
    #obtain galaxies that have 5 or more members 
    #loop through all galaxy id or is there a better option?
    
    
def crook_veldisp():
    
    #---------------------------------------
    #The goal of this function definition is to:
    # - zero down to groups that have 5 or more members
    # - obtain the vel dispersion of groups
    # - obtain the location of the groups (specifically the distance to the groups)
    # - plot vel disp as a function of distance to the groups
    #--------------------------------------

    #obtaining the group properties from val file 
    group_id = np.copy(val.group_id)
    gal_pos = np.copy(val.pos_icrs)
    gal_recvel = np.copy(val.rec_vel)
    gal_r = np.copy(val.abs_mag)
    gal_k = np.copy(val.abs_mag_k)

    #getting rid of isolated galaxies
    gal_pos = gal_pos[group_id != -1]
    gal_recvel = gal_recvel[group_id != -1]
    gal_r = gal_r[group_id != -1]
    gal_k = gal_k[group_id != -1]
    group_id = group_id[group_id != -1]
   

    gal_d = gal_recvel/100.

    #obtaining the unique id array
    groupid = np.unique(group_id)
    groupid = np.sort(groupid)

    #initializing new arrays
    groupngal = np.empty(len(groupid))
    #group_dist = np.empty(len(groupid))
    group_recvel_avg = np.empty(len(groupid))
    group_recvel_disp = np.empty(len(groupid))


    for j in range(len(groupid)):
        
        grid = groupid[j]

        #collecting the indices of the galaxies that belong to this group
        w = np.where(group_id == grid)[0]
        
        #collecting the number of galaxies belonging to this group and their recessional vel
        ngal = len(w)
        #if ngal < 5: continue
        recvelgal = gal_recvel[w]

        #plt.figure()
        #plt.hist(recvelgal)
        #plt.show()
        
    
        #obtaining the average recessional velocity 
        recvel_avg_group = np.mean(recvelgal)
        recvel_disp_group = np.std(recvelgal)

        group_recvel_avg[j] = recvel_avg_group
        group_recvel_disp[j] = recvel_disp_group
        groupngal[j] = ngal
        
        
    print(len(groupngal))
    print(np.mean(groupngal))
    print(len(group_recvel_avg))
    
    #collect the groups with 5 or more members 
    grp_d = group_recvel_avg[groupngal >= 5]/100.
    grp_recvel_disp = group_recvel_disp[groupngal >= 5]

    print(len(grp_d))

    d = recvel_disp_group/100.

    plt.figure()
    plt.plot(grp_d, grp_recvel_disp, linestyle = 'none', marker = '*')
    #plt.hist2d(grp_d, grp_recvel_disp, bins=60)
    plt.yscale("log")
    plt.xlabel("l.o.s Distance [Mpc]")
    plt.ylabel("l.o.s Velocity Dispersion [km/s]")
    #cbar = plt.colorbar()
    #cbar.set_label("Number of groups")
    plt.savefig("../plots/test4_marker.png")
    plt.show()



def rminusk():

    #---------------------------------
    #This function definition is to test r minus k
    
    #obtain r magnitude
    gal_r = np.copy(val.abs_mag)
    
    #regenrate k magnitude
    #obtain the z
    gal_pos = np.copy(val.pos)
    galx = gal_pos[:,0]; galy = gal_pos[:,1]; galz = gal_pos[:,2]
    d = np.sqrt(galx**2 + galy**2 + galz**2) 
    vh = 100.*d
    c = 2.98e5
    z = v/c

    
    
def groupprop():
    
    #------------------------------------------------
    #This functiond definition extracts the different properties
    #of the fof grouping algorithm
    #
    #To note: ngals = number of galaxies in a group defined as
    #         2 or more 
    #         ngals_true = number of galaxies in a group defined 
    #         as 3 or more
    #-----------------------------------------------

    #not considering the corner cases
    group_id = np.copy(val.group_id)[:len(val.group_id)/27]

    #total number of galaxies 
    ngalstot = len(group_id)
    print(ngalstot)


    #extract the number of singles 
    nsingles = len(group_id[group_id == -1])
    nsingles_per = nsingles*100./ngalstot



    #-----------------------------------------------------
    #calculate the number of galaxies in each group
    #extract unique group ids and remove -1 from it
    groupid = np.sort(np.unique(group_id))
    groupid = np.delete(groupid, 0)
    
    #groupid_ref is used instead of group_id to 
    #speed up the process
    groupid_ref = group_id[group_id != -1]
   
    ngals = np.empty(len(groupid))
    for j in range(len(groupid)):
        ngals[j] = len(groupid_ref[groupid_ref == groupid[j]])
        
    #-------------------------------------------------------

    #count the number of galaxies in binaries and number of binary pairs 
    nbinary_pairs = len(ngals[ngals == 2])
    nbinaries = nbinary_pairs*2.
    nbinaries_per = nbinaries*100./ngalstot

    #number of galaxies grouped in true groups
    #ngals_groupedtrue = np.sum(ngals[ngals >= 3])

    #count the number of true groups 
    #ngrp_3 = len(groupid[ngals >=3 ])
    nthrees = 0.
    for q in range(len(ngals)):
        if ngals[q] >= 3.:
            nthrees += ngals[q]
    nthrees_per = nthrees*100./ngalstot

    '''
    #number of groups with 3 <= ngals < 10
    ngrp_3_10 = len(np.where((ngals >= 3) & (ngals <10))[0])
    ngrp_3_10_per = ngrp_3_10*100./ngrp_3
    

    #count number of groups with >= 10 and < 50
    ngrp_10_50 = len(np.where((ngals >= 10) & (ngals <50))[0])
    ngrp_10_50_per = ngrp_10_50*(100./ngrp_3)

    #count number of 50s
    ngrp_50 = len(ngals[ngals >= 50])
    ngrp_50_per = ngrp_50*(100./ngrp_3)
   
    '''
    #greater than 10
    #ngrp_10 = len(groupid[ngals >= 10])
    ntens = 0.
    for q in range(len(ngals)):
        if ngals[q] >= 10.:
            ntens += ngals[q]
    ntens_per = ntens*100./ngalstot
    
    #greater than 50 
    #ngrp_50 = len(groupid[ngals >= 50])
    nfifties = 0.
    for q in range(len(ngals)):
        if ngals[q] >= 50.:
            nfifties += ngals[q]
    nfifties_per = nfifties*100./ngalstot


    #mean number and standard deviation of galaxies per true group
    nmean = np.mean(ngals[ngals >= 3])
    nstd = np.std(ngals[ngals >= 3])
    
    #minimum and maximum 
    nmin = np.min(ngals[ngals >= 3])
    nmax = np.max(ngals[ngals >= 3])


    #print percentages
    data_array = [nsingles_per, nbinaries_per, nthrees_per, ntens_per, nfifties_per, nmean, nstd, nmin, nmax]
    data_ar = [nsingles, nbinaries, nthrees, ntens, nfifties, nmean, nstd, nmin, nmax]
    

    print(data_array)
    print(data_ar)





def galden():
    path = "../data/800/galDenCom.hdf5"
    f = h5py.File(path, "r")
    print(f.keys())
    lo = f["lo"]; hi = f["hi"]; sim_num = f["sim_num"]; twomrs_num = f["twomrs_num"]
    #dist = np.append(lo, hi[-1])
    
    fig, ax = plt.subplots()
    plt.plot(hi, sim_num, linestyle = "none", marker = "*", label = "Periodic Sim box")
    plt.plot(hi, twomrs_num, linestyle = "none", marker = "*", label = "2MRS")
    #plt.yscale("log")
    plt.ylabel("Number of galaxies")
    plt.xlabel("Distance [Mpc*h]")
    plt.legend()
    plt.savefig("../plots/galDenCom.png", bbox_inches = "tight")
   
    plt.show()


def read2mrs(path):
    
    dat = ascii.read(path, include_names = ["ID", "RAdeg", "DEdeg",
                                            "GLON", "GLAT", "Kcmag", 
                                            "e_Kcmag", "cz", "e_cz"])

   

    dict_2mrs = dict(twomrsid = dat["ID"], radeg = dat["RAdeg"], 
                     decdeg = dat["DEdeg"], l = dat["GLON"], b = dat["GLAT"], 
                     Ks = dat["Kcmag"], e_Ks = dat["e_Kcmag"], 
                     recvel = dat["cz"], e_recvel = dat["e_cz"])
    
   
        
    #deleting the data where the recvel is not provided or when Ks >= 11.25
    del_array = []
    for i in range(len(dict_2mrs["recvel"])):
        if ma.is_masked(dict_2mrs["recvel"][i]):
            del_array.append(i)
        if dict_2mrs["Ks"][i] >= 11.25:
            del_array.append(i)
    for key in dict_2mrs:
        dict_2mrs[key] = np.delete(dict_2mrs[key], del_array)

    print(len(dict_2mrs["recvel"]))

    return dict_2mrs



def get_recvel(pos, vel):
    x = pos[:,0]; y = pos[:,1]; z = pos[:,2]
    vx = vel[:,0]; vy = vel[:,1]; vz = vel[:,2]
    d = np.sqrt(x**2 + y**2 + z**2)
    
    phinot = 39.*np.pi/180.
    #rotating the velocity vectors like the positional vectors
    vx = np.cos(phinot)*vx + np.sin(phinot)*vy + 0*vz
    vy = -np.sin(phinot)*vx + np.cos(phinot)*vy + 0*vz
    vz = vz
    
    #Hubble velocity 
    vh = 100.*d

    #los peculiar velocity 
    vpec_los = (vx*x + vy*y + vz*z)/d #same for both the coordinate systems since the origin doesn't change
    
    #total los recessional vel 
    c = 2.99e5
    zh = vh/c 
    zpec = vpec_los/c #change this to full form?
    ztotal = ((1+zh)*(1+zpec)) - 1
    vtotal_los = ztotal*c #change this to full form?

    #rotating the old velocity vectors

    #total los recessional vel 
    c = 2.99e5
    zh = vh/c 
    zpec = vpec_los/c #change this to full form?
    ztotal = ((1+zh)*(1+zpec)) - 1
    vtotal_los = ztotal*c #change this to full form?
    
    return vtotal_los

def raDec_sim():
    
    path_to_singleSim = "../data/800/singleSim_wovelcorr.hdf5"
    path_to_singleSim_raw = "../../myhod_wrapper/data/800/mock_cat.hdf5"
    path_to_periodicbox = "../data/800/periodic_box_wovelcorr.hdf5"
    path_to_sim = "/home/shivani.shah/Projects/LIGO/runs/Round6/run1/output"
    path_2mrs= "../../2mrs/data/2mrs.txt"

    #------------------------------------------------------
    halo_cat_instance = hod_wrap.halo_cat(path_to_sim)
    halo_cat = {}
    halo_cat["pos"] = halo_cat_instance.SubhaloPos
    halo_cat["vel"] = halo_cat_instance.SubhaloVel
    halo_cat = fd.modify_singleSim(halo_cat)
    halo_ra = halo_cat["ra"]
    halo_dec = halo_cat["dec"]
    #------------------------------------------------------

    nBins = 50
    #-----------------------------------------------------------------
    single_sim_raw_dict = fd.readFile(path_to_singleSim_raw)
    single_sim_raw_dict = fd.modify_singleSim(single_sim_raw_dict)
    #-----------------------------------------------------------------
    
    #----------------------------------------------------------
    single_sim_dict = fd.readFile(path_to_singleSim)
    sing_ra = single_sim_dict["ra"]
    sing_dec = single_sim_dict["dec"]
    sing_recvel = get_recvel(single_sim_dict["pos"], single_sim_dict["vel"])
    sing_x = sing_recvel*np.cos(sing_dec)*np.cos(sing_ra)
    sing_y = sing_recvel*np.cos(sing_dec)*np.sin(sing_ra)
    sing_z = sing_recvel*np.sin(sing_dec)
    sing_dat = np.stack((sing_x, sing_y, sing_z), axis=1)
    sing_tree = KDTree(sing_dat)
    #-------------------------------------------------------

    #---------------------------------------------------------
    period_sim_dict = fd.readFile(path_to_periodicbox)
    period_ra = period_sim_dict["ra"]
    period_dec = period_sim_dict["dec"]
    period_recvel = get_recvel(period_sim_dict["pos"], period_sim_dict["vel"])
    period_x = period_recvel*np.cos(period_dec)*np.cos(period_ra)
    period_y = period_recvel*np.cos(period_dec)*np.sin(period_ra)
    period_z = period_recvel*np.sin(period_dec)
    period_dat = np.stack((period_x, period_y, period_z), axis=1)
    period_tree = KDTree(period_dat)
    #--------------------------------------------------------
    
    #---------------------------------------------------------
    degtorad = np.pi/180.
    dict_2mrs = read2mrs(path_2mrs)
    twomrs_ra = dict_2mrs["radeg"]*degtorad
    wt = np.where(twomrs_ra > np.pi)
    twomrs_ra[wt] = twomrs_ra[wt] - 2*np.pi
    twomrs_dec = dict_2mrs["decdeg"]*degtorad
    twomrs_recvel = dict_2mrs["recvel"]
    twomrs_x = twomrs_recvel*np.cos(twomrs_dec)*np.cos(twomrs_ra)
    twomrs_y = twomrs_recvel*np.cos(twomrs_dec)*np.sin(twomrs_ra)
    twomrs_z = twomrs_recvel*np.sin(twomrs_dec)
    twomrs_dat = np.stack((twomrs_x, twomrs_y, twomrs_z), axis=1)
    twomrs_tree = KDTree(twomrs_dat)
    #---------------------------------------------------------
    
    #-----------------------------------------------------
    print(len(period_ra))
    print(len(sing_ra))
    print(len(twomrs_ra))
    #-----------------------------------------------------
    '''
    fig, ax1 = plt.subplots()
    _,_,_,h1 = ax1.hist2d(halo_ra, halo_dec, bins=nBins, norm = mlc.LogNorm())
    _,_,_,h2 = ax2.hist2d(period_ra, period_dec, bins= nBins, norm = mlc.LogNorm())
    

    #plt.colorbar(h1)
    #plt.colorbar(h2)
    plt.show()
    '''

    #-----------------Coma density-------------------------------------
    '''
    coma_ra = 194.952*degtorad 
    coma_dec = 28.297*degtorad 
    #coma_mass = np.log(2.1e15/solarmass) #http://hosting.astro.cornell.edu/academics/courses/astro7620/docs/a7620_cluster_mass_estimators.pdf
    if coma_ra > np.pi:
        coma_ra -= 2*np.pi
    #coma_z = 0.0234
    coma_z = 0.04
    c = 2.99e5
    coma_recvel = coma_z*c
    coma_x = coma_recvel*np.cos(coma_dec)*np.cos(coma_ra)
    coma_y = coma_recvel*np.cos(coma_dec)*np.sin(coma_ra)
    coma_z = coma_recvel*np.sin(coma_dec)
    coma_coord  = [coma_x, coma_y, coma_z] 
    vsearch = 2000.

    period_coma = len(period_tree.query_ball_point(coma_coord, vsearch))
    sing_coma = len(sing_tree.query_ball_point(coma_coord, vsearch))
    twomrs_coma = len(twomrs_tree.query_ball_point(coma_coord, vsearch))
    
    print(period_coma, sing_coma, twomrs_coma)
    '''
    #-------------------------------------------------------------------------
    '''
    bin_edges = np.arange(0.,500.*100., 10.*100.)
    period_hist, _ = np.histogram(period_recvel, bin_edges)
    sing_hist, _ = np.histogram(sing_recvel, bin_edges)
    twomrs_hist, _ = np.histogram(twomrs_recvel, bin_edges)
    fig, ax = plt.subplots()
    ax.plot(bin_edges[:-1], period_hist,label = "Periodic Sim",
            marker = "*")
    ax.plot(bin_edges[:-1], sing_hist, label = "Single Sim",
            marker = "*")
    ax.plot(bin_edges[:-1], twomrs_hist, label = "2MRS",
            marker = "*")
    xticks = [0, 2500, 5000, 10000, 20000, 30000, 40000, 50000]
    xticklabel = [0, 25, 50, 100, 200, 300, 400, 500]
    ax.set_xticks(xticks)
    ax.set_xticklabels(xticklabel)
    ax.set_xlabel("Distance*h [Mpc]")
    ax.set_ylabel("Number of Galaxies")
    plt.legend()
    plt.savefig("../plots/galDenCom_new.png", bbox_inches = "tight")
    #plt.show()
    sys.exit()
    '''
    radtodeg = 180./np.pi
    print(np.min(twomrs_ra), np.max(twomrs_ra))
    print(np.min(twomrs_dec), np.max(twomrs_dec))
    print(len(twomrs_ra))
    


    fig1 = plt.figure()
    ax = fig1.add_subplot(111, projection = "hammer")
    #ax = fig1.add_subplot(111)
    ax.scatter(twomrs_ra,twomrs_dec, s = 0.01, color = "grey")
    plt.grid()
    plt.savefig("../plots/skycoverage_twomrs.png", bbox_inches = "tight")
    plt.show()

    
#galden()

raDec_sim()


