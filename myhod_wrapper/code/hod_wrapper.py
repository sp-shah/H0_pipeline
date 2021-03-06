#Embedded file name: /home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/code/hod_wrapper.py
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
import matplotlib.pyplot as plt
import time
from mpi4py import MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

def main():
    if rank == 0:
        directory_hodsmith = '/home/shivani.shah/shahlabtools/Python/hod_new/hod'
        startTime = time.time()
        path_to_gal_dir = directory_hodsmith + '/output/800/cat_snapshot_observed.hdf5'
        props_gal = gal_properties(path_to_gal_dir)
        new_gal = remove_central(props_gal)
        
        path_to_halo_dir = '/home/shivani.shah/Projects/LIGO/runs/Round6/run1/output'
        cat = halo_cat(path_to_halo_dir)
        props_subhalo = remove_firstsub(cat)
        sys.exit()
        print time.time() - startTime
    else:
        props_subhalo = None
        new_gal = None
    comm.Barrier()
    props_subhalo = comm.bcast(props_subhalo, root=0)
    new_gal = comm.bcast(new_gal, root=0)
    startTime = time.time()
    fixed_gal = matching_fixing(props_subhalo, new_gal)
    if rank == 0:
        print 'Retrieving the centrals'
        cen_gal = retrieve_cen(props_gal)
        print 'Combing satellite and centrals'
        combine_gal = combine_cen_sat(fixed_gal, cen_gal)
        path_to_final_data = '/home/shivani.shah/Projects/LIGO/analysis/mock/myhod_wrapper/data/800/mock_cat_observed_again.hdf5'
        print 'writing the file'
        write_to_file(path_to_final_data, combine_gal)


def gal_properties(path_to_file):
    file_smith = h5py.File(path_to_file, 'r')
    abs_mag = file_smith['abs_mag'][:]
    halo_ind = file_smith['halo_ind'][:]
    is_cen = file_smith['is_cen'][:]
    pos = file_smith['pos'][:]
    vel = file_smith['vel'][:]
    halo_mass = file_smith['halo_mass'][:]
    file_smith.close()
    return dict(abs_mag=abs_mag, halo_ind=halo_ind, is_cen=is_cen, pos=pos, vel=vel, halo_mass=halo_mass)


def mag_cutoff(prop_gal):
    abs_mag = prop_gal['abs_mag']
    x = np.copy(prop_gal['pos'])[:, 0]
    y = np.copy(prop_gal['pos'])[:, 1]
    z = np.copy(prop_gal['pos'])[:, 2]
    d = np.sqrt(x ** 2 + y ** 2 + z ** 2)
    v = 100.0 * d
    c = 299000.0
    z = v / c
    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r = model.get_observed_absolute_mags(3.0, filters='sloan_r', zs=z, ab=True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters='ks', zs=z, vega=True)
    rminusk = abs_mag_r - abs_mag_ks
    abs_mag_k = abs_mag - rminusk
    K = abs_mag_k + 5.0 * np.log10(d) + 25.0
    prop_gal['K'] = K
    prop_gal['abs_mag_k'] = abs_mag_k
    wNan = np.where(np.isnan(prop_gal['abs_mag']))
    for key in prop_gal:
        prop_gal[key] = np.delete(prop_gal[key], wNan, axis=0)

    wKlim = np.where(K >= 11.25)[0]
    for key in prop_gal:
        print key
        prop_gal[key] = np.delete(prop_gal[key], wKlim, axis=0)

    return prop_gal


def halo_cat(path_to_file):
    snaps = glob.glob(path_to_file + '/snapdir*')
    s = len(snaps) - 1
    cat = readsubf.subfind_catalog(path_to_file, s, subcat=True, grpcat=True, keysel=['SubhaloVel',
                                                                                      'SubhaloPos',
                                                                                      'SubhaloGrNr',
                                                                                      'GroupNsubs',
                                                                                      'GroupFirstSub',
                                                                                      'SubhaloMass', 
                                                                                      'GroupMass',
                                                                                      'GroupVel', 
                                                                                      'GroupPos'])
    return cat


def remove_firstsub(cat):
    central_ind = cat.GroupFirstSub[cat.GroupNsubs >= 1]
    mass = np.delete(cat.SubhaloMass, central_ind)
    pos = np.delete(cat.SubhaloPos, central_ind, axis=0)
    vel = np.delete(cat.SubhaloVel, central_ind, axis=0)
    halo_ind = np.delete(cat.SubhaloGrNr, central_ind)
    sort_ind = np.argsort(mass)
    mass = np.flip(mass[sort_ind], axis=0)
    pos = np.flip(pos[sort_ind], axis=0)
    vel = np.flip(vel[sort_ind], axis=0)
    halo_ind = np.flip(halo_ind[sort_ind], axis=0)
    return dict(mass=mass, pos=pos, vel=vel, halo_ind=halo_ind)
    


def remove_central(gal):
    new_gal = {}
    for key in gal:
        if key != 'is_cen':
            if key == 'vel' or key == 'pos':
                new_gal[key] = gal[key][np.invert(gal['is_cen']), :]
            else:
                new_gal[key] = gal[key][np.invert(gal['is_cen'])]

    sort_ind = np.argsort(new_gal['abs_mag'])
    for key in new_gal:
        print key
        new_gal[key] = new_gal[key][sort_ind]

    return new_gal


def matching_fixing(subhalo, gal):
    print rank
    halo_indices = np.unique(gal['halo_ind'])
    nhalo = len(halo_indices)
    perrank = nhalo // size
    comm.Barrier()
    remove_gal = []
    remove_subhalo = []
    gal_ind_change = []
    sub_ind_change = []
    timear = []
    test_data = np.arange(0, rank)
    for j in range(rank * perrank, (rank + 1) * perrank):
        startTime = time.time()
        halo_index = halo_indices[j]
        sub_ind_true = np.where(subhalo['halo_ind'] == halo_index)[0]
        gal_ind_true = np.where(gal['halo_ind'] == halo_index)[0]
        if len(sub_ind_true) == 0:
            remove_gal.extend(gal_ind_true)
            continue
        if len(gal_ind_true) == 0:
            remove_subhalo.extend(sub_ind_true)
            nsub = len(sub_ind_true)
            print 'removed ' + np.str(nsub)
            continue
        if len(gal_ind_true) > len(sub_ind_true):
            gal_ind_remove = gal_ind_true[len(sub_ind_true):]
            remove_gal.extend(gal_ind_remove)
            gal_ind_true = gal_ind_true[:len(sub_ind_true)]
        if len(sub_ind_true) > len(gal_ind_true):
            sub_ind_remove = sub_ind_true[len(gal_ind_true):]
            nsub = len(sub_ind_remove)
            remove_subhalo.extend(sub_ind_remove)
            print 'removed ' + np.str(nsub)
            sub_ind_true = sub_ind_true[:len(gal_ind_true)]
        if len(sub_ind_true) != len(gal_ind_true):
            print 'False'
            sys.exit()
        else:
            gal_ind_change.extend(gal_ind_true)
            sub_ind_change.extend(sub_ind_true)
        if rank == 0:
            timear.append(time.time() - startTime)

    comm.Barrier()
    test_data = np.array(comm.gather(test_data, root=0))
    remove_gal = np.array(comm.gather(remove_gal, root=0))
    remove_subhalo = np.array(comm.gather(remove_subhalo, root=0))
    gal_ind_change = np.array(comm.gather(gal_ind_change, root=0))
    sub_ind_change = np.array(comm.gather(sub_ind_change, root=0))
    if rank == 0:
        remove_gal = np.concatenate(remove_gal)
        remove_subhalo = np.concatenate(remove_subhalo)
        gal_ind_change = np.concatenate(gal_ind_change)
        sub_ind_change = np.concatenate(sub_ind_change)
        print 'Shape remove gal'
        print np.shape(remove_gal)
        print len(remove_gal)
        print type(remove_gal)
        print 'remove subhalo'
        print remove_subhalo
        print len(remove_subhalo)
        print type(remove_subhalo)
        remaining_num = perrank % size
        last_rank = size - 1
        for j in range((last_rank + 1) * perrank, nhalo):
            startTime = time.time()
            halo_index = halo_indices[j]
            sub_ind_true = np.where(subhalo['halo_ind'] == halo_index)[0]
            gal_ind_true = np.where(gal['halo_ind'] == halo_index)[0]
            if len(sub_ind_true) == 0:
                remove_gal = np.append(remove_gal, gal_ind_true)
                continue
            if len(gal_ind_true) == 0:
                remove_subhalo = np.append(remove_subhalo, sub_ind_true)
                nsub = len(sub_ind_true)
                print 'Removed ' + np.str(nsub)
            if len(gal_ind_true) > len(sub_ind_true):
                gal_ind_remove = gal_ind_true[len(sub_ind_true):]
                remove_gal = np.append(remove_gal, gal_ind_remove)
                gal_ind_true = gal_ind_true[:len(sub_ind_true)]
            if len(sub_ind_true) > len(gal_ind_true):
                sub_ind_remove = sub_ind_true[len(gal_ind_true):]
                remove_subhalo = np.append(remove_subhalo, sub_ind_remove)
                nsub = len(remove_subhalo)
                print 'removed ' + np.str(nsub)
                sub_ind_true = sub_ind_true[:len(gal_ind_true)]
            if len(sub_ind_true) != len(gal_ind_true):
                print 'False'
                print len(sub_ind_true)
                print len(gal_ind_true)
                sys.exit()
            else:
                gal_ind_change = np.append(gal_ind_change, gal_ind_true)
                sub_ind_change = np.append(sub_ind_change, sub_ind_true)

        print 'Final Remove gal'
        print type(remove_gal.flatten())
        print len(remove_gal.flatten())
        print 'Final Remove subhalo'
        print type(remove_subhalo.flatten())
        print len(remove_subhalo.flatten())
        print np.shape(remove_subhalo.flatten())
        sys.exit()
        gal['remove_gal'] = remove_gal.flatten()
        gal['remove_subhalo'] = remove_subhalo.flatten()
        gal['gal_ind_change'] = gal_ind_change.flatten()
        gal['sub_ind_change'] = sub_ind_change.flatten()
        return gal
    else:
        return 0


def retrieve_cen(gal):
    for key in gal:
        if key != 'is_cen':
            gal[key] = gal[key][gal['is_cen']]

    return gal


def combine_cen_sat(sat, cen):
    pos = np.append(cen['pos'], sat['pos'], axis=0)
    abs_mag = np.append(cen['abs_mag'], sat['abs_mag'])
    vel = np.append(cen['vel'], sat['vel'], axis=0)
    halo_ind = np.append(cen['halo_ind'], sat['halo_ind'], axis=0)
    is_cen = np.append(np.ones(len(cen['abs_mag']), dtype=bool), np.zeros(len(sat['abs_mag']), dtype=bool))
    halo_mass = np.append(cen['halo_mass'], sat['halo_mass'])
    return dict(pos=pos, abs_mag=abs_mag, vel=vel, halo_ind=halo_ind, halo_mass=halo_mass, is_cen=is_cen, remove_gal=sat['remove_gal'], remove_subhalo=sat['remove_subhalo'], gal_ind_change=sat['gal_ind_change'], sub_ind_change=sat['sub_ind_change'])


def mag_conv(combine_gal):
    abs_mag = np.copy(combine_gal['abs_mag'])
    x = np.copy(combine_gal['pos'])[:, 0]
    y = np.copy(combine_gal['pos'])[:, 1]
    z = np.copy(combine_gal['pos'])[:, 2]
    d = np.sqrt(x ** 2 + y ** 2 + z ** 2)
    v = 100.0 * d
    c = 299000.0
    z = v / c
    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r = model.get_observed_absolute_mags(3.0, filters='sloan_r', zs=z, ab=True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters='ks', zs=z, vega=True)
    rminusk = abs_mag_r - abs_mag_ks
    abs_mag_k = abs_mag - rminusk
    combine_gal['abs_mag_k'] = abs_mag_k
    return combine_gal


def add_ra_dec_redshift(combine_gal):
    x = np.copy(combine_gal['pos'][:, 0])
    y = np.copy(combine_gal['pos'][:, 1])
    z = np.copy(combine_gal['pos'][:, 2])
    x -= 370.0
    y -= 370.0
    z -= 30.0
    phinot = 39.0 * np.pi / 180.0
    x = np.cos(phinot) * x + np.sin(phinot) * y + 0 * z
    y = -np.sin(phinot) * x + np.cos(phinot) * y + 0 * z
    z = z
    d = np.sqrt(x ** 2 + y ** 2 + z ** 2)
    ra = np.arctan2(y, x)
    dec = np.arcsin(z / d)
    c_icrs = SkyCoord(ra=ra * u.radian, dec=dec * u.radian, frame='icrs')
    l = np.array(c_icrs.galactic.l)
    b = np.array(c_icrs.galactic.b)
    degtorad = np.pi / 180.0
    l *= degtorad
    b *= degtorad
    combine_gal['ra'] = ra
    combine_gal['dec'] = dec
    combine_gal['l'] = l
    combine_gal['b'] = b
    x_gal = d * np.cos(b) * np.sin(l)
    y_gal = d * np.cos(b) * np.cos(l)
    z_gal = d * np.sin(b)
    pos_gal = np.stack((x_gal, y_gal, z_gal), axis=1)
    vx = np.copy(combine_gal['vel'][:, 0])
    vy = np.copy(combine_gal['vel'][:, 1])
    vz = np.copy(combine_gal['vel'][:, 2])
    vx = np.cos(phinot) * vx + np.sin(phinot) * vy + 0 * vz
    vy = -np.sin(phinot) * vx + np.cos(phinot) * vy + 0 * vz
    vz = vz
    vh = 100.0 * d
    vpec_los = (vx * x + vy * y + vz * z) / d
    c = 298000.0
    zh = vh / c
    zpec = vpec_los / c
    ztotal = (1 + zh) * (1 + zpec) - 1
    vtotal_los = ztotal * c
    return combine_gal


def write_to_file(path_to_file, mock_gal):
    f = h5py.File(path_to_file, 'w')
    group = f.create_group('sim1')
    vel = group.create_dataset('vel', data=mock_gal['vel'])
    pos = group.create_dataset('pos', data=mock_gal['pos'])
    abs_mag = group.create_dataset('abs_mag', data=mock_gal['abs_mag'])
    halo_ind = group.create_dataset('halo_ind', data=mock_gal['halo_ind'])
    halo_mass = group.create_dataset('halo_mass', data=mock_gal['halo_mass'])
    is_cen = group.create_dataset('is_cen', data=mock_gal['is_cen'])
    remove_gal = group.create_dataset('remove_gal', data=mock_gal['remove_gal'])
    remove_subhalo = group.create_dataset('remove_subhalo', data=mock_gal['remove_subhalo'])
    gal_ind_change = group.create_dataset('gal_ind_change', data=mock_gal['gal_ind_change'])
    sub_ind_change = group.create_dataset('sub_ind_change', data=mock_gal['sub_ind_change'])


if __name__ == '__main__':
    main()
