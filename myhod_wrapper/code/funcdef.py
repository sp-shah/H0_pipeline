import numpy as np
import h5py
import matplotlib.pyplot as plt
import hod_wrapper as hodWrap
import sys
from matplotlib import rc


rc('text', usetex=True) 
rc("text.latex", unicode = True)
rc("font", size =16., family = 'serif')



def read_cat(path):
    f = h5py.File(path, "r")
    s = f["sim1"]
    pos = s["pos"][:]
    vel = s["vel"][:]
    abs_mag = s["abs_mag"][:]
    halo_ind = s["halo_ind"][:]
    is_cen = s["is_cen"][:]
    halo_mass = s["halo_mass"][:]
    remove_gal = s["remove_gal"][:]
    remove_subhalo = s["remove_subhalo"][:]
    gal_ind_change = s["gal_ind_change"][:]
    sub_ind_change = s["sub_ind_change"][:]


    hod_dict = dict(pos = pos, vel = vel, abs_mag=abs_mag, 
                    halo_ind = halo_ind, is_cen = is_cen, 
                    halo_mass = halo_mass)


    tag = dict(remove_gal = remove_gal, remove_subhalo = remove_subhalo, 
               gal_ind_change = gal_ind_change,
               sub_ind_change = sub_ind_change)

    return hod_dict, tag




def read_sim(path_to_sim):
    sim_cat = hodWrap.halo_cat(path_to_sim)
    plt.figure()
    plt.hist(sim_cat.SubhaloMass, log = True, bins = 50)
    plt.ylabel(r"Number of Subhalos")
    plt.xlabel(r"Mass")
    plt.savefig("../plots/massTestSubhalos.png", bbox_inches = "tight")
    plt.show()
    centralInd = sim_cat.GroupFirstSub[sim_cat.GroupNsubs > 0]
    centralMass = sim_cat.SubhaloMass[centralInd]
    centralHaloInd = sim_cat.SubhaloGrNr[centralInd]
    sim_dict = hodWrap.remove_firstsub(sim_cat)
    sim_dict["centralMass"] = centralMass
    sim_dict["centralHaloInd"] = centralHaloInd
    #-----------------------------------------
    loneHaloInd = np.where(sim_cat.GroupNsubs == 0)[0]
    print(sim_cat.GroupMass[loneHaloInd])
    #--------------------------------------------
    sim_dict["loneHaloInd"] = loneHaloInd
    #-------------------------------------------
    #creating a dictionary for the group that can be used maybe
    #writing this dictionary into the mock_cat file 
    groupDict = dict(groupMass = sim_cat.GroupMass, 
                     groupPos = sim_cat.GroupPos, groupVel = sim_cat.GroupVel)

    return sim_dict, groupDict


def edit_cat(hod_dict, sim_dict, tag):

    is_cen = np.copy(hod_dict["is_cen"])
    isSat = np.where(is_cen == 0)[0]
    isCen = np.where(is_cen == 1)[0]

    #-------------------------------------------------------------
    #assign the mass of central satellites to central galaxies
    hod_dict["SubhaloMass"] = np.full(len(hod_dict["abs_mag"]), -1.)
    hod_HaloInd_centrals = hod_dict["halo_ind"][isCen]
   
    loneHaloInd = sim_dict["loneHaloInd"]
    #--the arrays below serve as indices to match the masses of the central galaxies
    hod_HaloInd_centrals = np.delete(hod_HaloInd_centrals, loneHaloInd)
    sim_HaloInd_centrals = sim_dict["centralHaloInd"]
    print(len(hod_HaloInd_centrals))
    print(len(sim_HaloInd_centrals))
    sys.exit()

    hod_dict["SubhaloMass"][hod_HaloInd_centrals] = sim_dict["centralMass"]
    print("Number of centrals in simulation with 0 mass")
    print(len(np.where(sim_dict["centralMass"] == 0.)[0]))
    hod_dict["SubhaloMass"][loneHaloInd] = hod_dict["halo_mass"][loneHaloInd]
    print("galaxies in hod with halo mass and equal to 0")
    print(len(np.where(hod_dict["halo_mass"][loneHaloInd] == 0.)[0]))
    #-------------------------------------------------------------------

    gal_ind_change = tag["gal_ind_change"].astype("int")
    sub_ind_change = tag["sub_ind_change"].astype("int")
    

    hod_dict["pos"][isSat][gal_ind_change] = sim_dict["pos"][sub_ind_change]
    hod_dict["vel"][isSat][gal_ind_change] = sim_dict["vel"][sub_ind_change]
    hod_dict["SubhaloMass"][isSat][gal_ind_change] = sim_dict["mass"][sub_ind_change]
    print("Number of satellites in simulation with 0 mass")
    print(len(np.where(sim_dict["mass"][sub_ind_change] == 0.)[0]))
    print("Total number of galaxies in mock")
    print(len(hod_dict["abs_mag"]))
    print("Total number of galaxies that are getting prop changes")
    print(len(gal_ind_change))

    print("Total mass assignment")
    a = len(sim_dict["mass"][sub_ind_change])
    print("a")
    print(a)
    b = len(sim_dict["centralMass"])
    print("b")
    print(b)
    print("Centrals in hOd + lone halos")
    print(len(hod_dict["SubhaloMass"][hod_HaloInd_centrals]) + len(loneHaloInd))
    c = len(hod_dict["halo_mass"][loneHaloInd])
    print(a+b+c)

    plt.figure()
    plt.hist(hod_dict["SubhaloMass"], bins = 50, log = True)
    plt.ylabel(r"Number of Galaxies")
    plt.xlabel(r"Mass")
    plt.savefig("../plots/massTestGalaxies_beforeRemoval.png", bbox_inches = "tight")
    plt.show()
    
    remove_gal = tag["remove_gal"].astype("int") + len(isCen) #collecting only sat gal
    #print(len(hod_dict["abs_mag"]))
    #print(len(remove_gal))
    abs_mag = hod_dict["abs_mag"]

    removed_abs_mag = abs_mag[remove_gal]
    #print(removed_abs_mag)
    '''
    plt.figure()
    plt.hist(removed_abs_mag, bins = 50)
    plt.yscale("log")
    plt.ylabel(r"Number\ of\ galaxies\ removed")
    plt.xlabel(r"$\mathrm{M_r}$")
    #plt.show()
    plt.savefig("../plots/galRemoved_dist.png", bbox_inches = "tight")
    '''
    for key in hod_dict:
        hod_dict[key] = np.delete(hod_dict[key], remove_gal, axis = 0)

    print("Number of galaxies being removed")
    print(len(remove_gal))
    print("Total number of galaxies remaining")
    print(len(hod_dict["abs_mag"]))
    print("Total number of galaxies with  0 mass")
    print(len(np.where(hod_dict["SubhaloMass"] == 0.)[0]))
    print("Total number of halos with 0 mass")
    print(len(np.where(hod_dict["halo_mass"] == 0.)[0]))

    
    plt.figure()
    plt.hist(hod_dict["SubhaloMass"], bins = 50, log = True)
    plt.ylabel(r"Number of galaxies")
    plt.xlabel(r"Mass")
    plt.savefig("../plots/massTestGalaxies_afterRemoval.png", bbox_inches = "tight")
    plt.show()

    
    remove_subhalo = tag["remove_subhalo"].astype("int")
    print(len(remove_subhalo))
    print(len(sim_dict["mass"]))
    for key in sim_dict:
        sim_dict[key] = np.delete(sim_dict[key], remove_subhalo, axis = 0)


    print("Total number of galaxies in sim dic")
    print(len(sim_dict["mass"]))
    
    
    sys.exit()

    return hod_dict
    

def write_newCat(mockEdited, path_to_mockEdited):
    
    f = h5py.File(path_to_mockEdited, "a")
    s = f.create_group("sim1")
    
    for key in mockEdited:
        key = s.create_dataset(key, data = mockEdited[key])


    
