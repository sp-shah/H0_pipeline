import numpy as np
from scipy.spatial import cKDTree as kdtree
import sys
from mpi4py import MPI
from datetime import datetime
import time
from astropy.coordinates import SkyCoord
from astropy import units as u
from itertools import chain as iterchain
import h5py
import string 
import random
from scipy.interpolate import RegularGridInterpolator as RGI
#import matplotlib
#matplotlib.use("agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy import interpolate
import values as val
from matplotlib.gridspec import GridSpec
import time
import ezgal

def flow_field_smoothing(dictionary):

    #initializing
    grid_int = 4.
    search_rad = 12.
    #12, 15, 20, 24, 28

    #obtaining the velocities
    vel = np.copy(dictionary["vel"])
    vx = vel[:,0]; vy = vel[:,1]; vz = vel[:,2]

    #obtaining the positions and making a tree
    pos = np.copy(dictionary["pos"])
    tree = kdtree(pos)
    
    #obtain the extent of the dimentions
    x = np.arange(0., 500. + grid_int, grid_int)
    y = np.copy(x); z = np.copy(x)
    
    #obtain the coordinates of the grids
    X,Y,Z = np.meshgrid(x, y, z)
    reshape_len = len(X[:,:,0])
    X = np.reshape(X, (-1))
    Y = np.reshape(Y, (-1))
    Z = np.reshape(Z, (-1))
    grid_pos = np.stack((X,Y,Z), axis = 1)
    print("Starting tree query")
    #enquiring the tree for every grid position
    ii = tree.query_ball_point(grid_pos, search_rad)
    print("Finish tree query")
    vel_avx = np.empty(len(ii
))
    vel_avy = np.empty(len(ii))
    vel_avz = np.empty(len(ii))
    print("started")
    for j in range(len(ii)):
        ar = ii[j]
        if len(ar) == 0:
            vel_avx[j] = 0.
            vel_avy[j] = 0.
            vel_avz[j] = 0.
        else:
            vel_avx[j] = np.mean(vx[ar])
            vel_avy[j] = np.mean(vy[ar])
            vel_avz[j] = np.mean(vz[ar])
    print("done")

    #taking the averages of the velocities at every grid position in each dimension
    #vel_avx = [np.mean(vx[ii[j]]) for j in range(len(ii))]
    #vel_avy = [np.mean(vy[ii[j]]) for j in range(len(ii))]
    #vel_avz = [np.mean(vz[ii[j]]) for j in range(len(ii))]

    #print(vel_avx)
    #print(vel_avy)
    #print(vel_avz)
    

    #obtaining the correct format for interpolator
    #reshape_len = 101
    vel_avx = np.reshape(vel_avx, (reshape_len, reshape_len, reshape_len))
    vel_avy = np.reshape(vel_avy, (reshape_len, reshape_len, reshape_len))
    vel_avz = np.reshape(vel_avz, (reshape_len, reshape_len, reshape_len))

    #feed this into an interpolator and get a function
    interpx = RGI((x, y, z), vel_avx, bounds_error = False, fill_value = 0., method = "linear") #is this okay
    interpy = RGI((x, y, z), vel_avy, bounds_error = False, fill_value = 0., method = "linear")
    interpz = RGI((x, y, z), vel_avz, bounds_error = False, fill_value = 0., method = "linear")


    ''''
    #use below in the case of testing out the velocity correction
    pos = np.copy(dictionary["pos"])
    posx = pos[:,0]; posy = pos[:,1]; posz = pos[:,2]

    w = np.where((posx <= 50.) & (posy <= 50.) & (posz <= 50.))[0]
    

    #obtain the vel correction at every gal position and correct for it
    vel_corrx = interpx(pos[w]) #is this okay
    vel_corry = interpy(pos[w])
    vel_corrz = interpz(pos[w])


    #new velocity components 
    vx_new = vx[w] - vel_corrx 
    vy_new = vy[w] - vel_corry 
    vz_new = vz[w] - vel_corrz 
    vel_new = np.stack((vx_new, vy_new, vz_new), axis = 1)
    

    #change the vel data of dictionary
    dictionary["vel_new"] = vel_new
    dictionary["vel_old"] = vel[w]
    '''
    #obtain the vel correction at every gal position and correct for it
    vel_corrx = interpx(pos) #is this okay
    vel_corry = interpy(pos)
    vel_corrz = interpz(pos)


    #new velocity components 
    vx_new = vx - vel_corrx 
    vy_new = vy - vel_corry 
    vz_new = vz - vel_corrz 
    vel_new = np.stack((vx_new, vy_new, vz_new), axis = 1)
    

    #change the vel data of dictionary
    dictionary["vel"] = vel_new
    dictionary["vel_old"] = vel
    

    return dictionary


def infallVel_correction(dictionary):


    pos = np.copy(dictionary["GalPos"][:])
    x = pos[:,0]; y = pos[:, 1]; z = pos[:, 2]
    

    ra = np.copy(dictionary["GalRArad"])
    dec = np.copy(dictionary["GalDECrad"][:])
    vtotal_los = np.copy(dictionary["GalHvel"][:])


   
    virgoRVel_lg = 957. #table A1 of Mould et al 2000
    virgoRVel_cosmic = 1350. # used in crook alg 
    virgoRAdeg = 187.83
    virgoDecdeg = 12.78
    virgoRA = virgoRAdeg * np.pi/180.
    virgoDec = virgoDecdeg * np.pi/180.

    angSep = 12.*np.pi/180. #degrees to radians
    separation = np.arccos(np.sin(virgoDec)*np.sin(dec) 
                           + np.cos(virgoDec)*np.cos(dec)*np.cos(virgoRA-ra))

    vtotal_los_corr = np.zeros(len(vtotal_los))
    for j in range(len(vtotal_los)):
        if (separation[j] < angSep) & (vtotal_los[j] < 2500.):
            vtotal_los_corr[j] = virgoRVel_lg
        else:
            vtotal_los_corr[j] = vtotal_los[j]
    
    
    #distance correction in the near universe 
    localvel = 3.*100. 
    wd = np.where(vtotal_los_corr < localvel)[0]
    vtotal_los_corr[wd] = localvel

    dictionary["distEst"] = vtotal_los_corr/val.H0 #Mpc true distance
    
    return dictionary
    
    



def build_distribution(dictionary):
    

    #vel = np.copy(dictionary["vel_new"])
    vel = np.copy(dictionary["vel"])
    vx = vel[:,0]; vy = vel[:,1]; vz = vel[:,2]
    vnew = np.sqrt(vx**2 + vy**2 + vz**2)
    
    velold = dictionary["vel_old"]
    vxold = velold[:,0]; vyold = velold[:,1]; vzold = velold[:,2]
    vold = np.sqrt(vxold**2 + vyold**2 +vzold**2)

    '''
    #print(np.min(vnew))
    #print(np.max(vnew))
    fig = plt.figure()
    gs = GridSpec(4,4)
    ax_joint = fig.add_subplot(gs[1:4, 0:3])
    ax_marg_x = fig.add_subplot(gs[0, 0:3], sharex = ax_joint)
    ax_marg_y = fig.add_subplot(gs[1:4, 3], sharey = ax_joint)
    ax_joint.scatter(vyold, vy, marker = '.', s=0.5, color ="tab:red")
    ax_marg_x.hist(vyold, bins = 50)
    ax_marg_y.hist(vy, bins = 50, orientation = "horizontal")
    y1,y2 = ax_joint.get_ylim()
    line = np.arange(y1, y2, 100)
    ax_joint.plot(line, line, color = "black")
    plt.savefig("../plots/flowfield/vy_srad12_grid4_linear.png")
    '''
    #fig, ax = plt.subplots()
    #ax.plot(vyold, vy, marker = '')


    
    plt.figure()
    plt.hist(vx, bins = 50, color = "tab:red")
    plt.hist(vxold, bins = 50, hatch = "/", color = "black", fill=0)
    plt.yscale("log")
    #plt.ylim((0.1,1.e3))
    #plt.xlim((0,2000.))
    plt.title("search radius = 12 Mpc")
    plt.savefig("../plots/flowfield/vx_srad12_grid4_dist.png")
   
    #plt.show()
    
    '''
    plt.figure()
    plt.hist(vold, bins = 30)
    plt.yscale("log")
    plt.ylim((0.1,1.e3))
    plt.xlim((0,2000.))
    plt.savefig("../plots/velcorr_abridged/distold.png")
    plt.title("Original Distribution")
    '''
    #plt.show()


def testing_subtraction(dictionary):

    #obtaining the properties
    pos = np.copy(dictionary["pos"])
    x = pos[:,0]; y = pos[:,1]; z = pos[:,2]
    w = np.where((x <= 20) & (y <= 20) & (z <= 20))[0]
    print(len(w))
   
    vel = np.copy(dictionary["vel"])
    velx = vel[:,0]; vely = vel[:,1]; velz = vel[:,2]
    vel_old = np.copy(dictionary["vel_old"])
    veloldx = vel_old[:,0]; veloldy = vel_old[:,1]; veloldz = vel_old[:,2]
    x = x[w]; y = y[w]; z= z[w]; vx = veloldx[w]; vy = veloldy[w]; vz = veloldz[w]
    vxn = velx[w]; vyn = vely[w]; vzn = velz[w]
    #plotting the data
    fig = plt.figure()
    ax = fig.gca(projection = '3d')
    #ax.quiver(x[::50], y[::50], z[::50], vx[::50], vy[::50], vz[::50], normalize = True, length = 15.)
    ax.quiver(x, y, z, vx, vy, vz, normalize = True, length = 2.)
    ax.quiver(x, y, z, vxn, vyn, vzn, normalize = True, length = 2., color = 'red')

    #ax.set_xlim((0,200))
    #ax.set_ylim((0,200))
    #ax.set_zlim((0,200))
    plt.show()
    

def testing_flowfield(dictionary):
    velnew = np.copy(dictionary["vel"])
    velx = velnew[:,0]; vely = velnew[:,1]; velz = velnew[:,2]
    velold = np.copy(dictionary["vel_old"])
    veloldx = velold[:,0]; veloldy = velold[:,1]; veloldz = velold[:,2]

    delx = np.abs(veloldx - velx); dely = np.abs(veloldy - vely); delz = np.abs(veloldz - velz)
    delv = np.sqrt(delx**2 + dely**2 + delz**2)

    fig, ax = plt.subplots()
    ax.hist(delv)
    plt.savefig("../plots/")
    



def periodicPos(pos):
    x = np.copy(pos[:,0]); y = np.copy(pos[:,1]); z = np.copy(pos[:,2])
    print(len(x))

    #building the center plane
    #to the right
    x1 = x + 500.; y1 = y; z1 = z
    #to the right top diagonal
    x2 = x + 500.; y2 = y + 500.; z2 = z
    #to the top
    x3 = x; y3 = y + 500.; z3 = z
    #to the left top diagonal 
    x4 = x - 500.; y4 = y + 500.; z4 = z
    #to the left
    x5 = x - 500.; y5 = y; z5 = z
    #to the left bottom diagonal 
    x6 = x - 500.; y6 = y - 500.; z6 = z
    #to the bottom 
    x7 = x; y7 = y-500.; z7 = z
    #to the bottom right
    x8 = x + 500; y8 = y - 500.; z8 = z
    x_center = np.append(x,[x1,x2,x3,x4,x5,x6,x7,x8])
    y_center = np.append(y, [y1,y2,y3,y4,y5,y6,y7,y8])
    z_center = np.append(z, [z1,z2,z3,z4,z5,z6,z7,z8])

    #back plane
    x_back = x_center; y_back = y_center; z_back = z_center + 500.
    
    #front plane
    x_front = x_center; y_front = y_center; z_front = z_center - 500.
 
    #final appending for to obtain 27 sim boxes
    x_periodic = np.append(x_center, [x_front, x_back])
    y_periodic = np.append(y_center, [y_front, y_back])
    z_periodic = np.append(z_center, [z_front, z_back])
    pos_periodic = np.stack([x_periodic, y_periodic, z_periodic], axis = 1)

    return pos_periodic

    
def periodicVel(vel):
    vx = vel[:,0]; vy = vel[:,1]; vz = vel[:,2]

    vx_center = np.append(vx, [vx, vx, vx, vx, vx,vx, vx, vx])
    vy_center = np.append(vy, [vy, vy, vy, vy, vy, vy, vy, vy])
    vz_center = np.append(vz, [vz, vz, vz, vz, vz, vz, vz, vz])

    vx_front = vx_center; vy_front = vy_center; vz_front = vz_center
    vx_back = vx_center; vy_back = vz_center; vz_back = vz_center


    vx_periodic = np.append(vx_center, [vx_front, vx_back])
    vy_periodic = np.append(vy_center, [vy_front, vy_back])
    vz_periodic = np.append(vz_center, [vz_front, vz_back])

    vel_periodic = np.stack([vx_periodic, vy_periodic, vz_periodic], axis = 1)
    
    return vel_periodic


def periodic(dictionary):
    print("here")
    startTime = time.time()
    GalPos = dictionary["GalPos"]
    GalPosPeriodic = periodicPos(GalPos)
    #---------------------------------------------------------------------------
    #Making halo position periodic
    HaloPos = dictionary["HaloPos"]
    HaloPosPeriodic = periodicPos(HaloPos)
    #-----------------------------------
    #duplicating the abs_mag
    GalAbsMag = list(np.copy(dictionary["GalAbsMag"]))
    GalAbsMagPeriodic = np.array(GalAbsMag *27)

    #duplicating the halo_id
    HaloInd = list(np.copy(dictionary["HaloInd"]))
    nHalos = len(np.unique(HaloInd))
    nGals  = len(HaloInd)
    HaloIndNew = HaloInd
    HaloIndPeriodic = []
    for j in range(27):
        HaloIndNew = np.array(HaloIndNew) + nHalos*j
        HaloIndPeriodic.extend(HaloIndNew)

    #du[licating halo_mass
    halo_mass = list(np.copy(dictionary["HaloMass"]))
    HaloMassPeriodic = np.array(halo_mass * 27)

    #HaloID 
    HaloIDPeriodic = np.arange(len(HaloMassPeriodic))

    #duplicating is_cen
    #is_cen = list(np.copy(dictionary["is_cen"]))
    #is_cen_periodic = np.array(is_cen * 27)

    #duplicationg subhalomass
    SubhaloMass = list(np.copy(dictionary["SubhaloMass"]))
    SubhaloMassPeriodic = np.array(SubhaloMass * 27)

    #duplicating abs_mag_k 
    #abs_mag_k = list(np.copy(dictionary["abs_mag_k"]))
    #abs_mag_k_periodic = np.array(abs_mag_k * 27)
    ###################################################################3
    #duplicating the corrected peculiar velocities
    vel = np.copy(dictionary["GalVel"])
    GalVelPeriodic = periodicVel(vel)

    HaloVel = np.copy(dictionary["HaloVel"])
    HaloVelPeriodic = periodicVel(HaloVel)

    ############################################################
    #duplicating the old peculiar velocities
    '''
    vel_old = np.copy(dictionary["vel_old"])
    vx = vel_old[:,0]; vy = vel_old[:,1]; vz = vel_old[:,2]

    vx_center = np.append(vx, [vx, vx, vx, vx, vx,vx, vx, vx])
    vy_center = np.append(vy, [vy, vy, vy, vy, vy, vy, vy, vy])
    vz_center = np.append(vz, [vz, vz, vz, vz, vz, vz, vz, vz])

    vx_front = vx_center; vy_front = vy_center; vz_front = vz_center
    vx_back = vx_center; vy_back = vz_center; vz_back = vz_center


    vx_periodic = np.append(vx_center, [vx_front, vx_back])
    vy_periodic = np.append(vy_center, [vy_front, vy_back])
    vz_periodic = np.append(vz_center, [vz_front, vz_back])

    vel_old_periodic = np.stack([vx_periodic, vy_periodic, vz_periodic], axis = 1)
    '''

    print("Periodic done")
    print(time.time() - startTime)


    periodicDict = {}
    periodicDict["GalPos"] = GalPosPeriodic
    periodicDict["GalVel"] = GalVelPeriodic
    periodicDict["HaloInd"] = HaloIndPeriodic
    periodicDict["SubhaloMass"] = SubhaloMassPeriodic
    periodicDict["GalAbsMag"] = GalAbsMagPeriodic
    periodicDict["HaloID"] = HaloIDPeriodic
    periodicDict["HaloPos"] = HaloPosPeriodic
    periodicDict["HaloVel"] = HaloVelPeriodic
    periodicDict["HaloMass"] = HaloMassPeriodic


    return periodicDict


    #return dict(pos_periodic = pos_periodic, abs_mag_periodic = abs_mag_periodic, vel_periodic = vel_periodic, is_cen_periodic = is_cen_periodic, halo_ind_periodic = halo_ind_periodic, halo_mass_periodic = halo_mass_periodic, SubhaloMass_periodic = SubhaloMass_periodic)#, abs_mag_k_periodic = abs_mag_k_periodic)#, vel_old_periodic = vel_old_periodic)


def modify_dictionary(dict_periodic):
    print("modify start")
    startTime = time.time()
    pos = np.copy(dict_periodic["GalPos"])
    x = pos[:,0]; y = pos[:,1]; z = pos[:,2]
    
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

    #ra, dec in galactic coordinates
    c_icrs = SkyCoord(ra=ra*u.radian, dec=dec*u.radian, frame='icrs')
    l = np.array(c_icrs.galactic.l)
    b = np.array(c_icrs.galactic.b)
    degtorad = np.pi/180.
    l *= degtorad #[0,2*pi]
    b *= degtorad #[-pi/2, pi/2]

    #obtain the corrected velocity vectors
    vel = np.copy(dict_periodic["GalVel"])
    vx = vel[:,0]
    vy = vel[:,1]
    vz = vel[:,2]

    #rotating the velocity vectors like the positional vectors
    vx = np.cos(phinot)*vx + np.sin(phinot)*vy + 0*vz
    vy = -np.sin(phinot)*vx + np.cos(phinot)*vy + 0*vz
    vz = vz


    
    #Hubble velocity 
    vh = 100.*d #km/s

    #los peculiar velocity 
    vpec_los = (vx*x + vy*y + vz*z)/d #same for both the coordinate systems since the origin doesn't change
    
    #total los recessional vel 
    c = 2.99e5
    zh = vh/c 
    zpec = vpec_los/c #change this to full form?
    ztotal = ((1+zh)*(1+zpec)) - 1
    vtotal_los = ztotal*c #change this to full form?
    '''
    #rotating the old velocity vectors

    vel_old = np.copy(dict_periodic["vel_old_periodic"])
    vx = vel_old[:,0]
    vy = vel_old[:,1]
    vz = vel_old[:,2]

    #rotating the velocity vectors like the positional vectors
    vx = np.cos(phinot)*vx + np.sin(phinot)*vy + 0*vz
    vy = -np.sin(phinot)*vx + np.cos(phinot)*vy + 0*vz
    vz = vz

    #Hubble velocity 
    vh = 100. * d

    #los peculiar velocity 
    vpec_los = (vx*x + vy*y + vz*z)/d #same for both the coordinate systems since the origin doesn't change
    
    #total los recessional vel 
    c = 2.99e5
    zh = vh/c 
    zpec = vpec_los/c #change this to full form?
    ztotal = ((1+zh)*(1+zpec)) - 1
    vtotal_old_los = ztotal*c #change this to full form?
    '''

    #finalizing the data 
    pos_periodic  = np.stack([x, y, z], axis = 1)
    vel_periodic = np.stack([vx, vy, vz], axis = 1)
    rec_vel_periodic = vtotal_los 
    #rec_vel_old_periodic = vtotal_old_los
    #abs_mag_periodic = dict_periodic["abs_mag_periodic"]
    ra_periodic = ra #radians [-pi, pi]
    dec_periodic = dec #radians [-pi/2, pi/2]
    l_periodic = l #radians range?
    b_periodic = b #radians range?

    
    print(len(b_periodic))

    print("modify done")
    print(time.time() - startTime)


    dict_periodic["GalPos"] = pos_periodic
    dict_periodic["GalVel"] = vel_periodic
    dict_periodic["GalRArad"] = ra_periodic
    dict_periodic["GalDECrad"] = dec_periodic
    dict_periodic["GalLONrad"] = l_periodic
    dict_periodic["GalLATrad"]  = b_periodic
    dict_periodic["GalHvel"] = rec_vel_periodic
    

    return dict_periodic
    
    #return dict(pos = pos_periodic, vel = vel_periodic, abs_mag = abs_mag_periodic, ra = ra_periodic, dec = dec_periodic, l = l_periodic, b = b_periodic, halo_ind = dict_periodic["halo_ind_periodic"], halo_mass = dict_periodic["halo_mass_periodic"], is_cen = dict_periodic["is_cen_periodic"], recvel = rec_vel_periodic, SubhaloMass = dict_periodic["SubhaloMass_periodic"])#, abs_mag_k_periodic = dict_periodic["abs_mag_k_periodic"])#, rec_vel_old_periodic = rec_vel_old_periodic)
    


def mag_cutoff(mock_cat):

    abs_mag = np.copy(mock_cat["GalAbsMag"])
    pos = np.copy(mock_cat["GalPos"])
    abs_mag_k, K = mag_conv(pos, abs_mag)
    mock_cat["GalAbsMagK"] = abs_mag_k
    mock_cat["GalK"] = K

    w = np.where(K < 11.25)[0]
       
    dontDEL = ["HaloID", "HaloMass", "HaloPos", "HaloVel", "removeGals", 
               "removeSubs"]

    for key in mock_cat:
        if key in dontDEL:
            continue
        mock_cat[key] = np.array(mock_cat[key])[w]


    x = mock_cat["GalPos"][:,0];y = mock_cat["GalPos"][:,1]
    z = mock_cat["GalPos"][:,2]
    d = np.sqrt(x**2 + y**2 + z**2)
    wd = np.where(d > 8.1)[0]
    for key in mock_cat:
        if key in dontDEL:
            continue
        #mock_cat[key] = np.delete(mock_cat[key], wd, axis = 0)
        mock_cat[key] = mock_cat[key][wd]

    return mock_cat



def read_periodic_box(path):
    
    f = h5py.File(path, "r")
    g = f["sim1"]
    pos_periodic = g["pos_periodic"][:]
    rec_vel_periodic = g["rec_vel_periodic"][:]
    rec_vel_old_periodic = g["rec_vel_old_periodic"][:]
    ra_periodic = g["ra_periodic"][:]
    dec_periodic = g["dec_periodic"][:]
    abs_mag_k_periodic = g["abs_mag_k_periodic"][:]
    
    dict_periodic_all = dict(pos_periodic = pos_periodic, rec_vel_periodic = rec_vel_periodic, ra_periodic = ra_periodic, dec_periodic = dec_periodic, abs_mag_k_periodic = abs_mag_k_periodic, rec_vel_old_periodic = rec_vel_old_periodic)

    

    return dict_periodic_all


def build_tree(dictionary):
    
    #obtaining the quantities from the dictionary
    ra = dictionary["ra_periodic"]; dec = dictionary["dec_periodic"]; rec_vel = dictionary["rec_vel_old_periodic"]
    #w1 = np.where((ra == np.float("inf") or ra == np.float("nan")))[0]
    #print(w1)
    #w2 = np.where((dec == np.float("inf") or ra == np.float("nan")))[0]
    #print(w2)
    #w3 = np.where(rec_vel == np.float("inf"))[0]
            
    
    #cartesian coordinates in the velocity space/
    x = rec_vel*np.cos(dec)*np.cos(ra)
    y = rec_vel*np.cos(dec)*np.sin(ra)
    z = rec_vel*np.sin(dec)
    pos = np.stack([x, y, z], axis=1)
    tree = kdtree(pos)

    return tree

def check_similiarity(dictionary, dict_periodic):
    pos_icrs = dictionary["pos_icrs"]
    pos_periodic = dict_periodic["pos_periodic"]
    print(pos_icrs[:2], pos_periodic[:,2])


def flat(ar):
    if np.isscalar(ar[0]):
        return ar
    else:
        chain = iterchain(*ar)
        return np.fromiter(chain, dtype = np.int)



def turnintoarray(a):
    if np.isscalar(a[0]):
        return np.array([a])
    ar = []
    for l in a:
        ar_list = []
        for ele in l:
            ar_list.append(ele)
        ar.append(ar_list)
    return ar



def fof_copy_copy(tree, dict_periodic, norm_factor, V0, D0, H0, mlim):
    
    #########################################################################33
    #number of queries that will be made - only from main simulation box
    n_gals = len(dict_periodic["pos_periodic"])/27

    #obtaining the properties from the periodic box
    #modifying abs_mag for cumulative lum function
    #corresponds to the k band magnitude
    abs_mag_k_periodic = np.copy(dict_periodic["abs_mag_k_periodic"])
    abs_mag = abs_mag_k_periodic[:len(abs_mag_k_periodic)/27]
    abs_mag = np.sort(abs_mag) #bright to faint
    abs_mag = abs_mag[::-1] #faint to bright 

    ra_periodic = np.copy(dict_periodic["ra_periodic"])
    dec_periodic = np.copy(dict_periodic["dec_periodic"])    
    rec_vel_old_periodic = np.copy(dict_periodic["rec_vel_old_periodic"])
    rec_vel_periodic = np.copy(dict_periodic["rec_vel_periodic"])


    #obtaining the 3D cartesian coodinates of position in velocity space
    x_periodic = rec_vel_old_periodic*np.cos(dec_periodic)*np.cos(ra_periodic)
    y_periodic = rec_vel_old_periodic*np.cos(dec_periodic)*np.sin(ra_periodic)
    z_periodic = rec_vel_old_periodic*np.sin(dec_periodic)
    pos_periodic = np.stack((x_periodic, y_periodic, z_periodic), axis = 1)
    n_periodic = len(pos_periodic)
    ####################################################################3
    groupid_counter = -1
    galaxy_isolated = np.zeros( n_periodic, dtype = bool )
    galaxy_grouped = np.zeros( n_periodic, dtype = bool )
    group_id = np.zeros( n_periodic, dtype = np.int)
    group_id.fill(-1)
    #####################################################################
    #initialize the cumulative luminosity function 
    f = cumlum_func()
    
    time_ar = []
    #n_gals = 1
    #main loop through all the galaxies of the main simulation box
    for i in range(n_gals):
        startTime = time.time()
        if galaxy_grouped[i]: 
            continue #if it is already grouped, skip
        if galaxy_isolated[i]: 
            continue #unecessary but a second check

        #else we will find friends
        query_ind = np.array([i])
        found_all = False
        isolated = False
        ind_thisgalaxy = [] #an array of the indices of the friends of this gal

        while found_all == False:
            #obtain indices of all galaxies within V0 of each query galaxy
            ii = tree.query_ball_point(pos_periodic[query_ind], V0)
            

            #check if it is isolated
            if len(flat(ii)) == len(query_ind): #excluding self membership
                isolated = True
                found_all = True
                galaxy_isolated[query_ind] = True
                continue

           
            #build corresponding query_ind structures for fast comparison 
            #in parallel linking length comparison
            query_ind_struct = np.empty(len(ii), dtype = object)
            for row in range(len(ii)):
                len_row = len(ii[row])
                query_row = np.empty(len_row)
                query_row.fill(query_ind[row])
                query_ind_struct[row] = query_row
           
            
            #now i have query_ind_struct and ii to compare
            ii = flat(ii); query_ind_struct = flat(query_ind_struct)

            #the following returns those galaxies that have passed the parallel 
            #linking length test
            ii_bool = par_check_copy(ii, query_ind_struct, norm_factor, 
                                     ra_periodic, dec_periodic, rec_vel_periodic, 
                                     abs_mag, D0, H0, mlim, f)
           
            ii = ii[ii_bool]
            if len(ii) <= len(query_ind): #excluding self membership --> confirm that self will be included
                isolated = True 
                found_all = True
                galaxy_isolated[query_ind] = True 
                continue

            unique_ii = np.setdiff1d(ii, ind_thisgalaxy)
            if len(unique_ii) == 0:
                found_all = True 
                continue 
            else:
                ind_thisgalaxy.extend(unique_ii)
                query_ind  = unique_ii
            

        if not isolated:
            
            groupid_counter += 1
            #print(groupid_counter)
            #print(ind_thisgalaxy)
            ind_thisgalaxy = np.array(ind_thisgalaxy)
            group_id[ind_thisgalaxy] = groupid_counter
            #print(group_id[ind_thisgalaxy])
            galaxy_grouped[ind_thisgalaxy] = True

        time_ar.append(time.time() - startTime)
        #print("Average time = {}.......".format(np.mean(time_ar)))
        if i%1000. == 0.:
            print("Time remaining = {}.....".format(np.mean(time_ar)*(n_gals-i)/360.))
            print("----------------------------")
    return dict(galaxy_grouped = galaxy_grouped, group_id = group_id)
                
###########################################################################################3333333

def par_check_copy(ii, query_ind_struct, norm_factor, ra_periodic, 
                   dec_periodic, rec_vel_periodic, 
                   abs_mag, D0, H0, mlim, f):

    #print(ii)
    #print(rec_vel_periodic[ii])
    #computing the linking length
    Vavg = (rec_vel_periodic[ii] + rec_vel_periodic[query_ind_struct])/2.
    #startTime2 = time.time()
    #print(Vavg)
    n_den = number_density_M12(abs_mag, Vavg, mlim, H0, f)
    #print(time.time() - startTime2)
    Dl = D0*(n_den/norm_factor)**(1./3.)
    #computing the separation
    ra_fof = ra_periodic[ii]; ra_f = ra_periodic[query_ind_struct]
    dec_fof = dec_periodic[ii]; dec_f = dec_periodic[query_ind_struct]
    #below taken from wiki :)
    theta = np.arccos(np.sin(dec_fof)*np.sin(dec_f) + np.cos(dec_fof)*np.cos(dec_f)*np.cos(ra_fof-ra_f))
    D12 = np.sin(theta/2)*Vavg/H0
    #print("------------------------------------------")
    #print("------------------------------------------")
    ii_bool = np.array(D12 < Dl)

    return ii_bool


def number_density_norm(dictionary, mlim, Vf, H0):
    
    #collecting the absolute magnitude from the dictionary
    abs_mag = dictionary["abs_mag_k"]
    #print(np.max(abs_mag))
    #f = cumlum_func()
    Mlim = mlim - 25. - 5*np.log10(Vf/H0)
    simulation_volume = 500.*500.*500.
    #number density of galaxies brighter than a limiting magnitude
    norm_factor = len(np.where(abs_mag < Mlim)[0])/(500.*500.*500)
    #norm_factor = f(Mlim)/simulation_volume
    
    return norm_factor

def number_density_M12(abs_mag, Vavg, mlim, H0, f):    
    
    #print(np.min(abs_mag), np.max(abs_mag))
    M12 = mlim - 25 - 5*np.log10(Vavg/H0)    
    #n_den = [f(M) for M in M12]
    simulation_volume = 500.*500.*500.
    ii = np.searchsorted(abs_mag, M12)
    n_den =  [len(abs_mag[ind:]) for ind in ii]
    n_den = np.array(n_den)/simulation_volume 
    return n_den


    '''
    n_den = [len(np.where(abs_mag_periodic < mag)[0]) for mag in M12]
    time_ar.append(time.time() - startTime)
    print("Average time = {}.......".format(np.mean(time_ar)))
    print("-------------------------")
    n_den = np.array(n_den, dtype = np.float64)/simulation_volume
    return n_den, time_ar
    '''


def cumlum_func():

    #This function definition creates an interpolating 
    #function out of the cumulative luminosity data 
    path_to_targetlf = "/home/shivani.shah/shahlabtools/Python/hod_test/hod/lookup/target_lf.dat"
    dat = np.genfromtxt(path_to_targetlf, names = ("mag", "phi"))
    mag = dat["mag"]
    phi = dat["phi"]
    f = interpolate.interp1d(mag, phi, bounds_error = False, fill_value = 0.)
    return f 


def schecterlum_func():
    abs_mag = np.arange(-24, -16, 0.1)
    phi_star = 1.08e-2 
    mchar = -24.2
    alpha = -1.02
    phi = 0.4*np.log(10)*phi_star*(10.**(0.4*(alpha+1)*(mchar - abs_mag)))*np.exp(-10.**(0.4*(mchar-abs_mag)))
    phi_cum = np.cumsum(phi)
    plt.plot(abs_mag, phi_cum)
    plt.show()
    



####################################################################################################3

def write_tofile(path, dictionary):
    f = h5py.File(path, "w")
    g = f.create_group("sim1")
    for key, values in dictionary.items():
        print(key)
        x = g.create_dataset(key, data = values)
    f.close()
        

########################################################################################################


def add_groupprop(group_dict, dict_periodic_all):
    
    #collecting all the properties
    group_id = np.copy(group_dict["group_id"])
    group_recvel = np.copy(dict_periodic_all["rec_vel_periodic"])
    
    #getting rid of isolated galaxies
    gal_recvel = gal_vel[group_id != -1]
    group_id = group_id[group_id != -1]

    #obtaining the unique id array
    groupid = np.unique(group_id)
    groupid = np.sort(groupid)

    #initializing new arrays
    groupngal = np.empty(len(groupid))
    group_recvel_avg = np.empty(len(groupid))
    group_recvel_disp = np.empty(len(groupid))
    
    
    for j in range(len(groupid)):
        
        grid = groupid[j]

        #collecting the indices of the galaxies that belong to this group
        w = np.where(group_id == grid)[0]
        
        #collecting the number of galaxies belonging to this group and their recessional vel
        ngal = len(w)
        recvelgal = gal_recvel[w]
    
        #obtaining the average recessional velocity 
        recvel_avg_group = np.mean(recvelgal)
        recvel_disp_group = np.std(recvelgal)

        group_recvel_avg[j] = recvel_avg_group
        group_recveldisp[j] = recvel_disp_group
        groupngal[j] = ngal


    group_dict["group_ngals"] = groupngal
    group_dict["group_recvel_mean"] = group_recvel_avg
    group_dict["group_recvel_disp"] = group_recvel_disp 

    return group_dict

########################################################################################################


def testing_scale(dictionary):
    #this function definition is capable of testing the 
    pos = np.copy(dictionary["pos"][:])
    x = pos[:,0]; y = pos[:, 1]; z = pos[:, 2]
    vel = np.copy(dictionary["vel"][:])
    vx = vel[:,0]; vy = vel[:,1]; vz = vel[:,2]
    
    #shift xyz positions to MW center
    x -= (370.)
    y -= (370.)
    z -= (30.)
    
    #rotate xyz positions
    phinot = (39.*np.pi/180.)
    x = np.cos(phinot)*x + np.sin(phinot)*y + 0*z
    y = -np.sin(phinot)*x + np.cos(phinot)*y + 0*z
    z = z


    #print the limits of x,y, z
    print("x, y and z ranges")
    print(np.min(x), np.max(x))
    print(np.min(y), np.max(y))
    print(np.min(z), np.max(z))
    
    
    #obtaining the distance to the galaxy
    d = np.sqrt(x**2 + y**2 + z**2) #[Mpc/h]

    #ra, dec in icrs coordinates
    ra = np.arctan2(y,x)  #RA in radians [-pi,pi]
    dec = np.arcsin(z/d)   #Declination in radians [-pi/2, pi/2]

    gaRA = val.ga_rarad
    gaDec = val.ga_decrad
    virgoRA = val.virgo_rarad 
    virgoDec = val.virgo_decrad 
    shapleyRA = val.shapley_rarad 
    shapleyDec = val.shapley_decrad

    gaDist = 4380./100. #D
    shapleyDist = 13600./100. #D
    virgoDist = 1350./100. #D
    
    #[x,y,z] coordinates of GA 
    gaX = gaDist*np.cos(gaRA)*np.cos(gaDec)
    gaY = gaDist*np.sin(gaRA)*np.cos(gaDec)
    gaZ = gaDist*np.sin(gaDec)

    #[x,y, z] coordinates of virgo 
    virgoX = virgoDist*np.cos(virgoRA)*np.cos(virgoDec)
    virgoY = virgoDist*np.sin(virgoRA)*np.cos(virgoDec)
    virgoZ = virgoDist*np.sin(virgoDec)
    
    print("Estimated location of the GA cluster")
    print(gaX, gaY, gaZ)
    
    print("Estimated location of the virgo cluster")
    print(virgoX, virgoY, virgoZ)
    

    

    #[x,y, z] coordinates of shapley 
    shapleyX = shapleyDist*np.cos(shapleyRA)*np.cos(shapleyDec)
    shapleyY = shapleyDist*np.sin(shapleyRA)*np.cos(shapleyDec)
    shapleyZ = shapleyDist*np.sin(shapleyDec)
    

    
    print("Estimated location of the SHAPLEY cluster")
    print(shapleyX, shapleyY, shapleyZ)
    


def mag_conv(pos, abs_mag):
    x = pos[:,0]; y = pos[:,1]; z= pos[:,2]
    d = np.sqrt(x**2 + y**2 + z**2)
    v = 100. * d #km/s
    c = 2.99e5
    z = v/c #true redsfhit of the galaxies
    

    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r = model.get_observed_absolute_mags(3.0, filters = "sloan_r", zs = z, ab = True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters = "ks", zs = z, vega = True)
    rminusk = abs_mag_r - abs_mag_ks
    abs_mag_k = abs_mag - rminusk #adding the r-k correction to r magntidues
    K = abs_mag_k + 5.*np.log10(d) + 25.

    return abs_mag_k, K



def mag_cutoff_singleSim(mock_cat):
    
    #This function definition will derinve K band 
    #magnitude and perform magnitude cutoff at K = 11.25

    abs_mag = np.copy(mock_cat["abs_mag"])
    pos = np.copy(mock_cat["pos"])
    abs_mag_k, K = mag_conv(pos, abs_mag)
    mock_cat["abs_mag_k"] = abs_mag_k
    mock_cat["K"] = K

    w = np.where(K < 11.25)[0]
       

    for key in mock_cat:
        mock_cat[key] = mock_cat[key][w]


    return mock_cat


def modify_singleSim(mock_cat):
     
    
    pos = np.copy(mock_cat["pos"])
    x = pos[:,0]; y = pos[:,1]; z = pos[:,2]
    
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

    #ra, dec in galactic coordinates
    c_icrs = SkyCoord(ra=ra*u.radian, dec=dec*u.radian, frame='icrs')
    l = np.array(c_icrs.galactic.l)
    b = np.array(c_icrs.galactic.b)
    degtorad = np.pi/180.
    l *= degtorad #[0,2*pi]
    b *= degtorad #[-pi/2, pi/2]

    pos_new = np.stack((x,y,z), axis = 1)

    vel = np.copy(mock_cat["vel"])
    vx = vel[:,0]
    vy = vel[:,1]
    vz = vel[:,2]
    #rotating the velocity vectors like the positional vectors
    vx = np.cos(phinot)*vx + np.sin(phinot)*vy + 0*vz
    vy = -np.sin(phinot)*vx + np.cos(phinot)*vy + 0*vz
    vz = vz
    
    #Hubble velocity 
    vh = 100.*d #km/s

    #los peculiar velocity 
    vpec_los = (vx*x + vy*y + vz*z)/d #same for both the coordinate systems since the origin doesn't change
    
    #total los recessional vel 
    c = 2.99e5
    zh = vh/c 
    zpec = vpec_los/c #change this to full form?
    ztotal = ((1+zh)*(1+zpec)) - 1
    vtotal_los = ztotal*c #change this to full form?

    vnew = np.stack((vx, vy, vz), axis=1)

    mock_cat["ra"] = ra
    mock_cat["dec"] = dec
    mock_cat["l"] = l
    mock_cat["b"] = b
    mock_cat["pos"] = pos_new
    mock_cat["vel"] = vnew
    mock_cat["recvel"] = vtotal_los

    return mock_cat


def readFile(path):

    f = h5py.File(path, "r")
    g = f["sim1"]
    keys = g.keys()
    mock_cat = {}
    for j in keys:
        mock_cat[j] = g[j][:]
        print(j)
    
    return mock_cat


def read_mock_cat(path):
    f = h5py.File(path)
    g = f["sim1"]
    keys = g.keys()
    print(keys[1])
