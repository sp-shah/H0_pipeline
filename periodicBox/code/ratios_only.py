#import values as val 
import h5py
import numpy as np
from mpi4py import MPI
import simread.readsubfHDF5 as readsubf
import glob
import sys
import sci_funcdef as sfd
from collections import Counter
import matplotlib.pyplot as plt
from matplotlib import rc

rc('text', usetex=True) 
rc("text.latex", unicode = True)
rc("font", size =18., family = 'serif')


comm = MPI.COMM_WORLD
rank = comm.Get_rank() #use 128?
size = comm.Get_size()


if rank ==0:
    path_to_group_info = "/home/shivani.shah/Projects/LIGO/analysis/mock/group_alg/data/800/fof_galgroups.hdf5"
    path_to_periodic_box = "/home/shivani.shah/Projects/LIGO/analysis/mock/group_alg/data/800/periodic_box.hdf5"
    
    #collect all fields of group info
    file1 = h5py.File(path_to_group_info, "r")
    sim1_file1 = file1["sim1"]
    galaxy_grouped_bool = sim1_file1["galaxy_grouped"][:]
    group_id = sim1_file1["group_id"][:]
    file1.close()

    #collect all the fields of the galaxies
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

    #pick an fof group
    ngroups = np.max(group_id) + 1
    halo_match = np.empty(ngroups)
    halo_match.fill(-1)
    ncompletion = np.empty(ngroups) #
    ncontamination = np.empty(ngroups)
    ncompletion.fill(-1)
    ncontamination.fill(-1)

    #halo indices of only the main periodic box
    halo_ind_main = halo_ind[:len(halo_ind)/27]
    
    
    
    #fig, (ax1, ax2) = plt.subplots(2,1)
    fig, ax1 = plt.subplots()

    group_id = group_id[group_id > -1]
    c = dict(Counter(group_id))
    x = c.values()
    #ax1.hist(x, fill = False, bins = 20, histtype = "step", color = 'k')
    ax1.hist(x, bins = 20, color = "crimson", label = "Mock Group Catalog")


    #fig.set_figheight(15)
    #fig.set_figwidth(7)
    #ax1.hist(x, color = "crimson")
    c = dict(Counter(halo_ind_main))
    x = c.values()
    ax1.hist(x, fill=False, histtype = "step", color = "k", hatch = "/", bins = 5, lw = 2., label = "FoF Catalog")
    ax1.set_yscale("log")
    ax1.set_xlim((-30,500))
    ax1.set_ylim(top = 1.e6)
    ax1.set_xlabel("Number of Members")
    ax1.set_ylabel("Number of Groups")
    #plt.savefig("../plots/crookfof_groupstats.png")
    #plt.show()
    w = np.where(x > 1)[0]
    print(np.max(x))

    group_id = group_id[group_id > -1]
    c = dict(Counter(group_id))
    x = c.values()
    #ax1.hist(x, fill = False, bins = 20, histtype = "step", color = 'k')
    #ax2.set_yscale("log")
    #ax2.set_xlim((0,500))
    #ax2.set_xlabel(r"Number of Members")
    #ax2.set_ylabel(r"Number of Groups")
    #plt.savefig("../plots/simfof_groupstats.png")
    
    for axis in ["top", "bottom", "left","right"]:
        ax1.spines[axis].set_linewidth(1.5)
    #for axis in ["top", "bottom", "left", "right"]:
        #ax2.spines[axis].set_linewidth(2.0)
    ax1.tick_params(direction='in',width= 1.5, size = 8)
    ax1.tick_params(direction='in',width= 0.5, size = 4, which= "minor")
    #ax2.tick_params(direction='in',width= 2.0, size = 10)
    #ax2.tick_params(direction='in',width= 0.5, size = 5, which = "minor")
    plt.legend()
    #plt.show()
    plt.savefig("../plots/sim&mock_comparison.png", bbox_inches = "tight")
    sys.exit()
    

    data = dict(group_id = group_id, halo_ind = halo_ind, abs_mag = abs_mag, ngroups = ngroups, halo_match = halo_match, ncompletion = ncompletion,
                ncontamination = ncontamination, halo_ind_main = halo_ind_main)

    print("Done")
else:
    data = None

data = comm.bcast(data, root = 0)

group_id = np.copy(data["group_id"])
halo_ind = np.copy(data["halo_ind"])
abs_mag = np.copy(data["abs_mag"])
ngroups = np.copy(data["ngroups"])
halo_match = np.copy(data["halo_match"])
ncompletion = np.copy(data["ncompletion"])
ncontamination = np.copy(data["ncontamination"])
halo_ind_main = np.copy(data["halo_ind_main"])

#--------------------------------------------
perrank = ngroups//size
remainder = ngroups - perrank*size
    
    
    
for j in range(rank*perrank, (rank+1)*perrank):
    groupnr = j
    if not groupnr%1000: print(groupnr)
    halo_match[j], ncompletion[j], ncontamination[j] = sfd.score_halos(groupnr, group_id, halo_ind, abs_mag, halo_ind_main)

        
if rank == 0:
    for j in range(perrank*size, ngroups):
        groupnr = j
        halo_match[j], ncompletion[j], ncontamination[j] = sfd.score_halos(groupnr, group_id, halo_ind, abs_mag, halo_ind_main)    
    

#gathering all the arrays
if size >1:
    halo_match = comm.gather(halo_match, root = 0)
    halo_match = np.ravel(halo_match)
    #ntotal = comm.gather(halo_match, root = 0)
    ncompletion = comm.gather(ncompletion, root = 0)
    ncompletion = np.ravel(ncompletion)
    ncontamination = comm.gather(ncontamination, root = 0)
    ncontamination = np.ravel(ncontamination)

    #comb through all the negaitve ones 
if rank ==0:
    remove_nones = [halo_match == -1]
    print(np.shape(halo_match))
    w = np.where(halo_match > -1)[0]
    print(np.shape(w))
    halo_match = np.array(halo_match)[w]
    ncompletion = np.array(ncompletion)[w]
    ncontamination = np.array(ncontamination)[w]
    #ntotal = ntotal[w]
    print(np.max(ncompletion))
    print(np.min(ncompletion))
    print(np.max(ncontamination))
    print(np.min(ncontamination))
    
    print(np.mean(ncompletion), np.mean(ncontamination))

    nhalo = np.float(len(np.unique(halo_ind_main)))
    print(nhalo)
    ngroups_found = np.float(len(ncompletion[ncompletion > 0.50]))/nhalo
    print(len(ncompletion[ncompletion > 0.50]))
    ninterlopers = (nhalo - ngroups_found)/nhalo
    print(ngroups_found, ninterlopers)





def score_halos(groupnr, halo_ind, abs_mag, halo_ind_main):
    groupnr = j
    
    print(groupnr)
    #collect the halo_ind, abs_mag_r/abs_mag of the galaxies belonging 
    #in this group
    halo_indices = halo_ind[group_id == groupnr]

    #----only groups that have three or more members
    if len(halo_indices) <= 2:
        return -1, -1, -1


    abs_magnitudes = abs_mag[group_id == groupnr]
    abs_mag_order = np.argsort(abs_magnitudes)
    rank = np.empty(len(abs_magnitudes))
    for k in range(len(abs_magnitudes)):
        w = np.where(k == abs_mag_order)[0]
        rank[k] = w[0] + 1 #rank starts at 1
        
    
        
    #loop through each galaxy,
    #in each loop give a score to the halo to which this galaxy belongs
    unique_halo_ind = np.unique(halo_indices)
    sum_rank = np.empty(len(unique_halo_ind), dtype = np.float)
    for i in range(len(unique_halo_ind)):
        w = [halo_indices == unique_halo_ind[i]]
        rank_resp = rank[w]
        rank_resp = 1./rank_resp**2
        sum_rank[i] = np.sum(rank_resp)

    w = [sum_rank == np.max(sum_rank)]
    halo_ind_match = unique_halo_ind[w]

    #count how many total galaxies belong to this winning halo
    winning_halo_count = [halo_ind_main == halo_ind_match]
    ntotal = len([winning_halo_count == True])
    
    #number fof galaxies that actually belong to this halo
    true_galaxy_count = [unique_halo_ind == halo_ind_match]
    ntrue = len(true_galaxy_count == True)
    ncompletion = ntrue/ntotal

    #number of foreign galaxies 
    nforeign = len(halo_indices) - ntrue
    ncontamination = nforeign/ntotal



    return halo_ind_match, ntotal, ncompletion, ncontamination
