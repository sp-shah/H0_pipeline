import numpy as np
#import val_sanitycheck as val
import sys


def score_halos(groupnr, group_id,halo_ind, abs_mag, halo_ind_main):

    
    #collect the halo_ind, abs_mag_r/abs_mag of the galaxies belonging 
    #in this group
    halo_indices = halo_ind[group_id == groupnr]

    #----only groups that have three or more members
    if len(halo_indices) <= 3:
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
    halo_ind_match = unique_halo_ind[w][0]

    
    #count how many total galaxies belong to this winning halo
    winning_halo_count = [halo_ind == halo_ind_match]
    ntotal = len([winning_halo_count == True])
    #print(ntotal)

    #number fof galaxies that actually belong to this halo
    true_galaxy_count = [halo_indices == halo_ind_match]
    ntrue = len([true_galaxy_count == True])
    #print(ntrue)
    ncompletion = ntrue/ntotal

    #number of foreign galaxies 

    nforeign = len(halo_indices) - ntrue
    #print(nforeign)
    ncontamination = nforeign/ntotal
    
    
    return halo_ind_match, ncompletion, ncontamination



def ratios(comm, rank, size):

    print(rank)
    print(size)
    sys.exit()
    
    group_id = np.copy(val.group_id)
    halo_ind = np.copy(val.halo_ind)
    abs_mag = np.copy(val.abs_mag)

    #pick an fof group
    ngroups = np.max(group_id) + 1
    halo_match = np.empty(len(group_id))
    halo_match.fill(-1)

    #--------------------------------------------
    perrank = ngroups//size
    remainder = ngroups - perrank*size

    
    
    for j in range(rank*perrrank, (rank+1)*perrank):
        groupnr = j
        halo_match[j] = score_halos(groupnr)

        
    if rank == 0:
        for j in range(perrank*size, ngroups):
             groupnr = j
             halo_match[j] = score_halos(groupnr)
            
