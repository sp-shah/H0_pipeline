import numpy as np
import os
import glob
import simread.readsubfHDF5 as readsubf
import h5py
import sys
from astropy.coordinates import SkyCoord
from astropy import units as u
import ezgal
import matplotlib
#matplotlib.use("agg")
import matplotlib.pyplot as plt
import time
from mpi4py import MPI


comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()


def main():
    
    if rank == 0:

        #make sure the input file for hod_smith has been created. currently the sim file is 
        #Round6/run1 and located at /home/shivani.shah/shahlabtools/Python/hod/mydir/data/snapshot
        #_input.hdf5 
    
        directory_hodsmith = '/home/shivani.shah/shahlabtools/Python/hod_new/hod'

        startTime = time.time()
        #obtaining the properties of the data file from hod smith
        path_to_gal_dir = directory_hodsmith + '/output/800/cat_snapshot_observed.hdf5'
        props_gal       = gal_properties(path_to_gal_dir)
    

        #obtaining the properties of only the satellite galaxies ordered from 
        #the satellites are ordered from brightest to faintest
        new_gal         = remove_central(props_gal)
    

        #obtaining the catalog information from Arepo (Round6/run1) with the central removed
        path_to_halo_dir = '/home/shivani.shah/Projects/LIGO/runs/Round6/run1/output'
        cat              = halo_cat(path_to_halo_dir)
        props_subhalo    = remove_firstsub(cat) #first subhalo corresponds to the central subhalo

        print(time.time() - startTime)


    else:
        props_subhalo = None
        new_gal = None

    comm.Barrier()

    props_subhalo = comm.bcast(props_subhalo, root = 0)
    new_gal = comm.bcast(new_gal, root = 0)

    #obtaining the new galaxy catalog
    #the following will match the pos and velocity of the brightest 
    #satellite galaxies to the biggest subhalos in the same halo
    startTime=time.time()
    fixed_gal = matching_fixing(props_subhalo, new_gal)
    #print(time.time() - startTime)
    
    if rank ==0:
        print("Retrieving the centrals")
        #retrieving only the centrals
        cen_gal = retrieve_cen(props_gal)
        print("Combing satellite and centrals")
        #combine the centrals and satellites to form one dict of positions and abs_mag
        combine_gal = combine_cen_sat(fixed_gal, cen_gal)
    
        #convert the r band magnitudes to K band using ezgal 
        #mock_gal = mag_conv(combine_gal)
        
        ####add ra and dec to the dictionary
        ###mock_gal = add_ra_dec_redshift(combine_gal)
        
        #write new pos and vel datasets to the hdf5 file
        path_to_final_data = "/home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/data/800/mock_cat_observed_again.hdf5"
        print("writing the file")
        write_to_file(path_to_final_data, combine_gal)

   
def gal_properties(path_to_file):


    file_smith = h5py.File(path_to_file, "r")
    abs_mag    = file_smith["abs_mag"][:]
    halo_ind   = file_smith["halo_ind"][:]
    is_cen     = file_smith["is_cen"][:]
    pos        = file_smith["pos"][:]
    vel        = file_smith["vel"][:]
    halo_mass  = file_smith["halo_mass"][:]
    file_smith.close()

    return dict(abs_mag = abs_mag, halo_ind = halo_ind, is_cen = is_cen, pos = pos, vel = vel, halo_mass = halo_mass)


def mag_cutoff(prop_gal):
    
    abs_mag = prop_gal["abs_mag"]
    
    #calculating the hubble redshift using comoving distance
    #at the present time comoving distance = porper distance
    x = np.copy(prop_gal["pos"])[:,0]
    y = np.copy(prop_gal["pos"])[:,1]
    z = np.copy(prop_gal["pos"])[:,2]

    d = np.sqrt(x**2 + y**2 + z**2) #[Mpc/h]
    v = 100. *d #km/s
    c = 2.99e5
    z = v/c
    
    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r = model.get_observed_absolute_mags(3.0, filters = "sloan_r", zs = z, ab = True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters = "ks", zs = z, vega = True)
    rminusk = abs_mag_r - abs_mag_ks    
    abs_mag_k = abs_mag - rminusk #adding the r-k correction to r magntidues
    K = abs_mag_k + 5.*np.log10(d) + 25.
    

    prop_gal["K"] = K 
    prop_gal["abs_mag_k"] = abs_mag_k


    wNan = np.where(np.isnan(prop_gal["abs_mag"]))
    for key in prop_gal:
        prop_gal[key] = np.delete(prop_gal[key], wNan, axis = 0)
        #else:
        #    prop_gal[key] = np.delete(prop_gal[key], wNan)

    wKlim = np.where(K >= 11.25)[0]

    for key in prop_gal:
        print(key)
        #if key == "pos":
        prop_gal[key] = np.delete(prop_gal[key], wKlim, axis = 0)
        #else:
        #    prop_gal[key] = np.delete(prop_gal[key], wKlim)
   
        
    return prop_gal



def halo_cat(path_to_file):
    snaps = glob.glob(path_to_file+"/snapdir*")
    s     = len(snaps) - 1
    cat   = readsubf.subfind_catalog(path_to_file, s, subcat = True, grpcat = True,
                                   keysel = ['SubhaloVel','SubhaloPos','SubhaloGrNr','GroupNsubs',
                                             'GroupFirstSub','SubhaloMass'])
    
    
    return cat

def remove_firstsub(cat):

    #collect the indices of the most massive subhalos
    central_ind = cat.GroupFirstSub[cat.GroupNsubs >= 0]
    
    #removing all the central/most massive subhalos
    mass        = np.delete(cat.SubhaloMass, central_ind)
    pos         = np.delete(cat.SubhaloPos, (central_ind), axis = 0)
    vel         = np.delete(cat.SubhaloVel, (central_ind), axis = 0)
    halo_ind    = np.delete(cat.SubhaloGrNr, (central_ind))
    

    #sorting all the properties by mass descending order
    sort_ind = np.argsort(mass)
    mass = np.flip(mass[sort_ind], axis = 0)
    pos = np.flip(pos[sort_ind], axis = 0)
    vel = np.flip(pos[sort_ind], axis = 0)
    halo_ind = np.flip(halo_ind[sort_ind], axis = 0)

    return dict(mass = mass, pos = pos, vel = vel, halo_ind = halo_ind)


def remove_central(gal):

    #removing the central galaxies from every property of the gal dictionary
    #except "is_cen" and returning the new array

    new_gal = {}
    
    for key in gal:
        if key != "is_cen":
            if key == "vel" or key == "pos":
                new_gal[key] = gal[key][np.invert(gal["is_cen"]), :]
            else:
                new_gal[key] = gal[key][np.invert(gal["is_cen"])]
    
    #sorting all the properties by the absolute magnitude to obtain galaxies from brightest
    #to faintest
    sort_ind = np.argsort(new_gal["abs_mag"])
    for key in new_gal:
        print(key)
        new_gal[key] = new_gal[key][sort_ind]

    return new_gal #abs_mag, halo_ind, pos, vel of satellites




def matching_fixing(subhalo, gal):

    #----------------setting up the parallelization----------------------
    print(rank)
    halo_indices = np.unique(gal["halo_ind"])
    nhalo = len(halo_indices)
    perrank = nhalo//size
    comm.Barrier() #lets all the processes catch up here
    #-------------------------------------------------------------------
    remove_gal = []
    remove_subhalo = []
    gal_ind_change = []
    sub_ind_change = []
    timear = []

    #-------------------------------------------------------------------
    #loop through each halo, pick out the subhalos belonging to it
    #and pick out the galaxies belonging to it to perform the 
    #matching
    
    test_data = np.arange(0,rank)
    
    for j in range(rank*perrank, (rank+1)*perrank):
        startTime = time.time()
        halo_index = halo_indices[j]
        #---------------------------------------------------------------------
        sub_ind_true = np.where(subhalo["halo_ind"] == halo_index)[0]
        gal_ind_true = np.where(gal["halo_ind"] == halo_index)[0]
        #----------------------------------------------------------------------
    
        #if there are no subhalos corresponding to this halo, discard
        #all the satellite galaxies that belong to this halo
        #i.e., we will assign no satellite galaxies to this halo
        if len(sub_ind_true) == 0:
            remove_gal.extend(gal_ind_true)
            #for key in gal:
            #    gal[key] = np.delete(gal[key], gal_ind_true, axis = 0)
            continue
        
        if len(gal_ind_true) == 0:
            remove_subhalo.extend(sub_ind_true)
            nsub = len(sub_ind_true)
            print("removed " + np.str(nsub))
            continue

               
        #if more galaxies than subhalos, remove the extra smaller galaxies
        if len(gal_ind_true) > len(sub_ind_true):
            gal_ind_remove = gal_ind_true[len(sub_ind_true):]
            remove_gal.extend(gal_ind_remove)
            #for key in gal:
            #    gal[key] = np.delete(gal[key], gal_ind_remove, axis = 0)
            #updating the gal_ind_true
            gal_ind_true = gal_ind_true[:len(sub_ind_true)]


        #if more subhalos than galaxies, remove the extra subhalos
        if len(sub_ind_true) > len(gal_ind_true):
            sub_ind_remove = sub_ind_true[len(gal_ind_true):]
            nsub = len(sub_ind_remove)
            remove_subhalo.extend(sub_ind_remove)
            print("removed " + np.str(nsub))
            #for key in subhalo:
            #    subhalo[key] = np.delete(subhalo[key], sub_ind_remove, axis = 0)
            #updating the sub_ind_true
            sub_ind_true = sub_ind_true[:len(gal_ind_true)]


        if len(sub_ind_true) != len(gal_ind_true):
            print("False")
            sys.exit()
        else:
            gal_ind_change.extend(gal_ind_true)
            sub_ind_change.extend(sub_ind_true)
                
        #for remaining samples, do the matching 
        #gal["pos"][gal_ind_true] = subhalo["pos"][sub_ind_true]
        #gal["vel"][gal_ind_true] = subhalo["vel"][sub_ind_true]
        
        if rank ==0:
            timear.append(time.time() - startTime) 
            #print("Time remaining = {}.....".format(np.mean(timear)*((perrank-j)/3600.)))
            #print("----------")

   
    comm.Barrier()
    test_data = np.array(comm.gather(test_data, root =0))
    remove_gal = np.array(comm.gather(remove_gal, root = 0))
    remove_subhalo = np.array(comm.gather(remove_subhalo, root = 0))
    gal_ind_change = np.array(comm.gather(gal_ind_change, root = 0))
    sub_ind_change = np.array(comm.gather(sub_ind_change, root = 0))
    if rank == 0:
        remove_gal = np.concatenate(remove_gal)
        remove_subhalo = np.concatenate(remove_subhalo)
        gal_ind_change = np.concatenate(gal_ind_change)
        sub_ind_change = np.concatenate(sub_ind_change)

        print("Shape remove gal")
        print(np.shape(remove_gal))
        print(len(remove_gal))
        print(type(remove_gal))

        print("remove subhalo")
        print(remove_subhalo)
        print(len(remove_subhalo))
        print(type(remove_subhalo))

        #finish off the rest of the halos 
        remaining_num = perrank%size 
        #print("Number of galaxies remaining")
        #print(remaining_num)
        last_rank = size - 1
        #print("Total number of halos")
        #print(nhalo)
        for j in range((last_rank+1)*perrank, nhalo):
            startTime = time.time()
            halo_index = halo_indices[j]
            #---------------------------------------------------------------------
            sub_ind_true = np.where(subhalo["halo_ind"] == halo_index)[0]
            #print("--------------------")
            #print(len(sub_ind_true))
            gal_ind_true = np.where(gal["halo_ind"] == halo_index)[0]
            #print(len(gal_ind_true))
            #----------------------------------------------------------------------
            
            #if there are no subhalos corresponding to this halo, discard
            #all the satellite galaxies that belong to this halo
            #i.e., we will assign no satellite galaxies to this halo
            if len(sub_ind_true) == 0:
                remove_gal = np.append(remove_gal, gal_ind_true)
                #for key in gal:
                #    gal[key] = np.delete(gal[key], gal_ind_true, axis = 0)
                #print("Here")
                continue

            if len(gal_ind_true) ==0:
                remove_subhalo = np.append(remove_subhalo, sub_ind_true)
                nsub = len(sub_ind_true)
                print("Removed " + np.str(nsub))
               
            #if more galaxies than subhalos, remove the extra smaller galaxies
            if len(gal_ind_true) > len(sub_ind_true):
                gal_ind_remove = gal_ind_true[len(sub_ind_true):]
                remove_gal = np.append(remove_gal, gal_ind_remove)
                #for key in gal:
                #    gal[key] = np.delete(gal[key], gal_ind_remove, axis = 0)
                #updating the gal_ind_true
                gal_ind_true = gal_ind_true[:len(sub_ind_true)]
            
            #if more subhalos than galaxies, remove the extra subhalos
            if len(sub_ind_true) > len(gal_ind_true):
                sub_ind_remove = sub_ind_true[len(gal_ind_true):]
                remove_subhalo = np.append(remove_subhalo, sub_ind_remove)
                nsub = len(remove_subhalo)
                print("removed " + np.str(nsub))
                #for key in subhalo:
                #    subhalo[key] = np.delete(subhalo[key], sub_ind_remove, axis = 0)
                #updating the sub_ind_true
                sub_ind_true = sub_ind_true[:len(gal_ind_true)]


            if len(sub_ind_true) != len(gal_ind_true):
                print("False")
                print(len(sub_ind_true))
                print(len(gal_ind_true))
                sys.exit()
            else:
                gal_ind_change = np.append(gal_ind_change, gal_ind_true)
                sub_ind_change = np.append(sub_ind_change, sub_ind_true)
                #gal_ind_change.extend(gal_ind_true)
                #sub_ind_change.extend(sub_ind_true)


        print("Final Remove gal")
        #print(remove_gal.flatten())
        print(type(remove_gal.flatten()))
        print(len(remove_gal.flatten()))
        print("Final Remove subhalo")
        #print(remove_subhalo.flatten())
        print(type(remove_subhalo.flatten()))
        print(len(remove_subhalo.flatten()))
        print(np.shape(remove_subhalo.flatten()))

        sys.exit()
        
        gal["remove_gal"] = remove_gal.flatten()
        gal["remove_subhalo"] = remove_subhalo.flatten()
        gal["gal_ind_change"] = gal_ind_change.flatten()
        gal["sub_ind_change"] = sub_ind_change.flatten()

        


        return gal
    else:
        return 0


def retrieve_cen(gal):

    for key in gal:
        if key != "is_cen":
            gal[key] = gal[key][gal["is_cen"]]
    
    return gal



def combine_cen_sat(sat, cen):
    
    pos = np.append(cen["pos"], sat["pos"], axis = 0)
    abs_mag = np.append(cen["abs_mag"], sat["abs_mag"])
    vel = np.append(cen["vel"], sat["vel"], axis = 0)
    halo_ind = np.append(cen["halo_ind"], sat["halo_ind"], axis = 0)
    is_cen = np.append(np.ones(len(cen["abs_mag"]), dtype = bool), np.zeros(len(sat["abs_mag"]),dtype = bool))
    halo_mass = np.append(cen["halo_mass"], sat["halo_mass"])
    #abs_mag_k = np.append(cen["abs_mag_k"], sat["abs_mag_k"])
    #K = np.append(cen["K"], sat["K"])


    return dict(pos = pos, abs_mag = abs_mag, vel = vel, halo_ind = halo_ind, halo_mass = halo_mass, 
                is_cen = is_cen, remove_gal = sat["remove_gal"], remove_subhalo = sat["remove_subhalo"],
                gal_ind_change = sat["gal_ind_change"], sub_ind_change = sat["sub_ind_change"])#halo_edit = sat["halo_edit"], halo_edit_mem = sat["halo_edit_mem"], abs_mag_k = abs_mag_k, K = K)



def mag_conv(combine_gal):
    
    abs_mag = np.copy(combine_gal["abs_mag"])


    #calculating the hubble redshift using comoving distance
    #at the present time comoving distance = porper distance
    x = np.copy(combine_gal["pos"])[:,0]
    y = np.copy(combine_gal["pos"])[:,1]
    z = np.copy(combine_gal["pos"])[:,2]

    d = np.sqrt(x**2 + y**2 + z**2) #[Mpc/h]
    v = 100. *d #km/s
    c = 2.99e5
    z = v/c

    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r = model.get_observed_absolute_mags(3.0, filters = "sloan_r", zs = z, ab = True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters = "ks", zs = z, vega = True)
    rminusk = abs_mag_r - abs_mag_ks
    
    abs_mag_k = abs_mag - rminusk #adding the r-k correction to r magntidues

    combine_gal["abs_mag_k"] = abs_mag_k

    return combine_gal

def add_ra_dec_redshift(combine_gal):

    #obtain x,y,z positions
    x = np.copy(combine_gal["pos"][:,0])
    y = np.copy(combine_gal["pos"][:,1])
    z = np.copy(combine_gal["pos"][:,2])
    
    #shift xyz positions
    x -= (370.)
    y -= (370.)
    z -= (30.)
    
    #rotate xyz positions
    phinot = (39.*np.pi/180.)
    x = np.cos(phinot)*x + np.sin(phinot)*y + 0*z
    y = -np.sin(phinot)*x + np.cos(phinot)*y + 0*z
    z = z

    #obtaining the distance to the galaxy [same in both the coordinate
    #systems since the origin hasn't changed]
    d = np.sqrt(x**2 + y**2 + z**2) #[Mpc/h]

    #ra, dec in icrs coordinates
    ra = np.arctan2(y,x)  #RA in radians [-pi,pi]
    dec = np.arcsin(z/d)   #Declination in radians [-pi/2, pi/2]

    #ra, dec in galactic coordinates
    c_icrs = SkyCoord(ra=ra*u.radian, dec=dec*u.radian, frame='icrs')
    l = np.array(c_icrs.galactic.l)
    b = np.array(c_icrs.galactic.b)
    degtorad = np.pi/180.
    l *= degtorad #[0,2*pi]
    b *= degtorad #[-pi/2, pi/2]

    #add to the dictionary
    combine_gal["ra"] = ra
    combine_gal["dec"] = dec
    combine_gal["l"] = l
    combine_gal["b"] = b

    #conver the galactic l and b to cartesian !!!!!!!CHECK THIS!!!!!!!!!!!!!!!!!!!!
    x_gal = d*np.cos(b)*np.sin(l)
    y_gal = d*np.cos(b)*np.cos(l)
    z_gal = d*np.sin(b)
    pos_gal = np.stack((x_gal, y_gal, z_gal), axis = 1)

    #obtain the velocity vectors
    vx = np.copy(combine_gal["vel"][:,0])
    vy = np.copy(combine_gal["vel"][:,1])
    vz = np.copy(combine_gal["vel"][:,2])

    #rotating the velocity vectors like the positional vectors
    vx = np.cos(phinot)*vx + np.sin(phinot)*vy + 0*vz
    vy = -np.sin(phinot)*vx + np.cos(phinot)*vy + 0*vz
    vz = vz

    #Hubble velocity 
    vh = 100. * d

    #los peculiar velocity 
    vpec_los = (vx*x + vy*y + vz*z)/d #same for both the coordinate systems since the origin doesn't change
    
    #total los recessional vel 
    c = 2.98e5
    zh = vh/c 
    zpec = vpec_los/c
    ztotal = ((1+zh)*(1+zpec)) - 1
    vtotal_los = ztotal*c
    
    

    return combine_gal




def write_to_file(path_to_file, mock_gal):
    
    f = h5py.File(path_to_file, "w")
    group = f.create_group("sim1")
   
    vel = group.create_dataset("vel", data = mock_gal["vel"])
    pos = group.create_dataset("pos", data = mock_gal["pos"])
    abs_mag = group.create_dataset("abs_mag", data = mock_gal["abs_mag"])
    halo_ind = group.create_dataset("halo_ind", data = mock_gal["halo_ind"])
    halo_mass = group.create_dataset("halo_mass", data = mock_gal["halo_mass"])
    is_cen = group.create_dataset("is_cen", data = mock_gal["is_cen"])
    #abs_mag_k = group.create_dataset("abs_mag_k", data = mock_gal["abs_mag_k"])
    #halo_edit = group.create_dataset("halo_edit", data = mock_gal["halo_edit"])
    #halo_edit_mem = group.create_dataset("halo_edit_mem", data = mock_gal["halo_edit_mem"])
    #K =  group.create_dataset("K", data = mock_gal["K"])
    
    remove_gal = group.create_dataset("remove_gal", data = mock_gal["remove_gal"])
    remove_subhalo =  group.create_dataset("remove_subhalo", data = mock_gal["remove_subhalo"])
    gal_ind_change =  group.create_dataset("gal_ind_change", data = mock_gal["gal_ind_change"])
    sub_ind_change =  group.create_dataset("sub_ind_change", data = mock_gal["sub_ind_change"])


    #DON't NEED
    '''
    ra = group.create_dataset("ra", data = mock_gal["ra"])
    dec = group.create_dataset("dec", data = mock_gal["dec"])
    dist = group.create_dataset("dist", data = mock_gal["dist"])
    l = group.create_dataset("l", data = mock_gal["l"])
    b = group.create_dataset("b", data = mock_gal["b"])
    rec_vel = group.create_dataset("rec_vel", data = mock_gal["rec_vel"])
    pos_gal = group.create_dataset("pos_gal", data=mock_gal["pos_gal"])
    pos_icrs = group.create_dataset("pos_icrs", data=mock_gal["pos_icrs"])
    vel_icrs = group.create_dataset("vel_icrs", data=mock_gal["vel_icrs"])
    '''
if __name__ == "__main__":
    main()
