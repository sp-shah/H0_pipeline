import funcdef as fd
import sys

def main():

    path_to_mock_cat = "/home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/data/800/mock_cat.hdf5"
    mock_cat = fd.readFile(path_to_mock_cat)

    modify_mock = fd.modify_singleSim(mock_cat)

    final_mock = fd.mag_cutoff_singleSim(modify_mock)
    
    path_to_magcutoff = "../data/800/singleSim_wovelcorr_new.hdf5"
    fd.write_tofile(path_to_magcutoff, final_mock)
    
    #correct for virgo infall 
    mock_wovelcorr = fd.readFile(path_to_magcutoff)
    mock_wvelcorr = fd.infallVel_correction(mock_wovelcorr)
    path_to_wvelcorr = "../data/800/singleSim_wvelcorr.hdf5"
    fd.write_tofile(path_to_wvelcorr, mock_wvelcorr)




if __name__ == "__main__":
    main()
