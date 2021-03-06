import h5py
import numpy as np

#for grouping algorithm using the


#path_to_gal_values = "/home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/data/800/mock_cat_n18.hdf5"
path_to_cat = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/800/cat_snapshot_observed.hdf5"

path_to_periodic_box = "/home/shivani.shah/Projects/LIGO/analysis/mock/group_alg/data/800/periodic_box_n18.hdf5"
#f = h5py.File(path_to_gal_values, "r")
g = h5py.File(path_to_cat, "r")
#g = f["sim1"]
abs_mag = g["abs_mag"][:]
pos = g["pos"][:]
vel = g["vel"][:]
halo_ind = g["halo_ind"][:]
halo_mass = g["halo_mass"][:]
is_cen = g["is_cen"][:]
#abs_mag_k = g["abs_mag_k"][:]
abs_mag_k = g["abs_mag"][:]
#don't need
'''
ra = g["ra"][:]
dec = g["dec"][:]
l = g["l"][:]
b = g["b"][:]
pos_gal = g["pos_gal"][:]
rec_vel = g["rec_vel"][:]
pos_icrs = g["pos_icrs"][:]
vel_icrs = g["vel_icrs"][:]
'''

dictionary = dict(pos = pos, abs_mag = abs_mag, vel = vel, halo_ind = halo_ind, is_cen = is_cen, halo_mass = halo_mass, abs_mag_k = abs_mag_k)#, rec_vel = rec_vel, ra = ra, dec = dec, l = l, b = b, pos_icrs = pos_icrs, vel_icrs = vel_icrs)


#fof parameters from crook et al. 2007
mlim = 11.25 #K band apparent mag threshold  
Vf = 1000. #fiducial recessional velocity [km/s]
h = 0.73
H0 = 100.*h 
V0 = 350. #perpendicular linking length km/s  
D0 = 0.56 #Mpc
degtorad = np.pi/180.


path_to_group_info = "/home/shivani.shah/Projects/LIGO/analysis/mock/group_alg/data/800/fof_galgroups.hdf5"


#Collecting the recessional velocities of Virgo, GA and Shapley from table A1 of Mould et al. 2000
#in the local group frame of reference
#virgo_rec_lg = 957. #lg velocity
virgo_rec_lg = 1350. #cosmic velocity
#ga_rec_lg = 4380.
ga_rec_lg = 4600.
#shapley_rec_lg = 13600.
shapley_rec_lg = 13800.

#Collecting the angular distance cut-off from Crook et al. 2007 (Distance estimate section)
virgo_theta = 12.
ga_theta = 10.
shapley_theta = 12.


#Collecting the recessional velocity cut-off from Crook et al. 2007. These are in heliocentric reference frame
virgo_rec_cutoff = 2500.
virgo_rec_cutoff = 1200.
ga_rec_cutoff = 2000.
shapley_rec_cutoff = 3000.


#RA and dec from Mould et al. 2000. RA [0,2*pi] dec [-pi/2, pi/2]
#degtorad = np.pi/180.
#virgo_ra = (12. + 28./60. + 19./360.)*15*degtorad
#virgo_dec = 12. + 40./60*degtorad
#ga_ra = (13. + 20./60.)*15*degtorad
#ga_dec = -44*degtorad
#shapley_ra = (13. + 30.)*15*degtorad
#shapley_dec = -31*degtorad


#collecting the ra, dec of the clusters 
virgo_radeg = 187.83
ga_radeg = 158.
shapley_radeg = 196.5

virgo_rarad = virgo_radeg*degtorad
ga_rarad = ga_radeg*degtorad
shapley_rarad = ga_radeg*degtorad


#declination 
virgo_decdeg = 12.78
ga_decdeg = -46.
shapley_decdeg = -33.07

virgo_decrad = virgo_decdeg*degtorad
ga_decrad = ga_decdeg*degtorad
shapley_decrad = shapley_decdeg*degtorad


#indicative distance in the local universe
recvel_cutoff = H0*3.
