import values as val
import h5py
import numpy as np
import sys
import simread.readsubfHDF5 as readsubf
import glob

path_to_group_info = "/home/shivani.shah/Projects/LIGO/analysis/mock/group_alg/data/800/fof_galgroups.hdf5"
path_to_periodic_box = "/home/shivani.shah/Projects/LIGO/analysis/mock/group_alg/data/800/periodic_box.hdf5"

#collect all fields of group info
file1 = h5py.File(path_to_group_info, "r")
sim1_file1 = file1["sim1"]
galaxy_grouped_bool = sim1_file1["galaxy_grouped"][:]
group_id = sim1_file1["group_id"][:]
file1.close()

#collect all the fileds of the galaxies
file2 = h5py.File(path_to_periodic_box, "r")
sim1_file2 = file2["sim1"]
ra = sim1_file2["ra_periodic"][:]
dec = sim1_file2["dec_periodic"][:]
pos_icrs = sim1_file2["pos_periodic"][:] 
vel_icrs = sim1_file2["vel_periodic"][:]
rec_vel = sim1_file2["rec_vel_periodic"][:]
abs_mag = sim1_file2["abs_mag_periodic"][:]
abs_mag_k = sim1_file2["abs_mag_k_periodic"][:]
is_cen = sim1_file2["is_cen_periodic"][:]
halo_mass = sim1_file2["halo_mass_periodic"][:]
halo_ind = sim1_file2["halo_ind_periodic"][:]
#l = sim1_file2["l_periodic"][:]
#b = sim1_file2["b_periodic"][:]
file2.close()

#collect all the fields of the simulation
path_to_sim = "/home/shivani.shah/Projects/LIGO/runs/Round6/run1/output" 
snaps = glob.glob(path_to_sim+"/snapdir*")
s     = len(snaps) - 1
cat   = readsubf.subfind_catalog(path_to_sim, s, subcat = True, grpcat = True,
                                 keysel = ['SubhaloVel','SubhaloPos','SubhaloGrNr','GroupNsubs', 'GroupFirstSub','SubhaloMass', 'Group_M_Mean200', 'GroupPos', 'GroupVel'])

groupmass = cat.Group_M_Mean200 
grouppos = cat.GroupPos
groupvel = cat.GroupVel 
subpos =  cat.SubhaloPos
subvel = cat.SubhaloVel 
groupnsubs = cat.GroupNsubs 
subgrnr = cat.SubhaloGrNr

