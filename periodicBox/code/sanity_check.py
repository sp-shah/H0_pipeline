import sanitycheck_funcdef as fd
import numpy as np

def main():
    
    #obtain processed arrays
    #group_id_rel, group_id_uniq = fd.array_processing()
   
    #distribution of number of galaxies per group
    #fd.hist_ngals(group_id_rel, group_id_uniq)
    
    #3D distribution of galaxies
    #fd.threed_spherical(group_id_rel, group_id_uniq)


    #
    #fd.threed_subsection()
    
    #fd.massive_halos()
    
    #fd.gal_ofpophalo()

    #fd.crook_veldisp()
    
    fd.groupprop()


if __name__ == "__main__":
    main()




#Names defined
#galaxy_grouped_bool = boolean array specifying whether the galaxy is grouped
#                      or not. 
#group_id = an array specifying which group the galaxy belongs to. An id of 
#           -1 indicates that the galaxy is isolated
#
#group_id_rel = an array of relevant group ids i.e., an a
#rray of group ids of 
#               only those galaxies that have been grouped
#group_id_uniq = a sorted array of group id numbers
