import values as val
import h5py
import numpy as np
import funcdef as fd
import sys



def main():

    #fd.testing_scale(val.dictionary)
    

    #correct for the local density fields
    #dict_corrected = fd.flow_field_smoothing(val.dictionary)
    
    
    #test the flow field correction
    #fd.build_distribution(dict_corrected)
    path_to_mock = "/home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/data/1600/run2_linkinglengths/0p3mps/mock_cat.hdf5"
    mock_cat = fd.readFile(path_to_mock)

    #make the simulation box periodic
    dict_periodic = fd.periodic(mock_cat)
    
    
    #modify the cooridnate system, add ra, dec, l, b
    dict_periodic_all = fd.modify_dictionary(dict_periodic)

    #magnitude cutoff
    dict_final = fd.mag_cutoff(dict_periodic_all)

    #sys.exit()
    
    #correct for the infall velocity of virgo
    #dict_final = fd.infallVel_correction(dict_periodic)
    
    
    #write to an hdf5 file that can be simply read after
    path_to_periodic_box = "../data/1600/run2_linkinglengths/0p3mps/periodic_box_wovelcorr85.hdf5"
    fd.write_tofile(path_to_periodic_box, dict_final)
    
    #vel correction around virgo 
    dict_wovelcorr = fd.readFile(path_to_periodic_box)
    dict_wvelcorr = fd.infallVel_correction(dict_wovelcorr)
    path_to_final_periodic_box = "../data/1600/run2_linkinglengths/0p3mps/periodic_box_wvelcorr85.hdf5"
    fd.write_tofile(path_to_final_periodic_box, dict_wvelcorr)

if __name__ == "__main__":
    main()
