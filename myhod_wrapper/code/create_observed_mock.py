import numpy as np
import funcdef as fd

def main():
    #read the true mock cat
    path_to_mock = "/home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/data/800/mock_cat_wrapper.hdf5"
    hod_dict, tag = fd.read_cat(path_to_mock)
   
    #read sim data and get rid of centrals
    path_to_sim = '/home/shivani.shah/Projects/LIGO/runs/Round6/run1/output'
    sim_dict,groupDict = fd.read_sim(path_to_sim)

    #remove the extra galaxies/subhalos
    mockEdited = fd.edit_cat(hod_dict, sim_dict, tag)
    mockEdited.update(groupDict)
    
    #write to a new file
    path_to_mockEdited = '/home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/data/800/mock_catwmass.hdf5' 
    fd.write_newCat(mockEdited, path_to_mockEdited)




if __name__ == "__main__":
    main()
