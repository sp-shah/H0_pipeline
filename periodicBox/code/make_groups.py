import values as val #this module will read in all the values from the data file
import funcdef as fd
import sys
from mpi4py import MPI
import time
#__________________________________________________________#
#comm = MPI.COMM_WORLD()
#rank = comm.Get_rank()
#total_ranks = 200
#__________________________________________________________#

def main():

    startTime = time.time()

    #read in all the values of the periodic box
    dict_periodic_all = fd.read_periodic_box(val.path_to_periodic_box)


    #build a tree out of the 27 simulation boxes
    tree = fd.build_tree(dict_periodic_all)

    #norm_factor
    norm_factor = fd.number_density_norm(val.dictionary, val.mlim, val.Vf, val.H0)
    
    #querying the tree using the main simulation box data points
    group_dict = fd.fof_copy_copy(tree, dict_periodic_all,  norm_factor, val.V0, val.D0, val.H0, val.mlim)

    #add properties to the group dictionary
    #group_dict = fd.add_groupprop(group_dict, dict_periodic_all)

    #write to a file
    fd.write_tofile(val.path_to_group_info,group_dict)

    print("Total time taken:")
    print((time.time() - startTime)/60.)

if __name__ == "__main__":
    main()
    
