#--------------------------------------------------------------
#The goal of this pipeline is to obtain create a catalog of galaxies
#with position and velocity equal to those of the subhalos in simulation 
#and absolute magnitude given by the HOD. 
#It is of hope to retain the number of galaxies per halo as given 
#by the HOD, however, this wasn't possible with the 800 cubed sim
#catalog, becuase of lower resolution. It is to be seen if 1600 cubed
#would work.
#The catalog will be, hopefully, arranged in the descending order
#of halos and their corresponding subhalos, in descendign order as well
#by mass
#--------------------------------------------------------------

import numpy as np
import os
import glob
import simread.readsubfHDF5 as readsubf
import h5py
import sys
from astropy.coordinates import SkyCoord
from astropy import units as u
import ezgal
#import matplotlib
#import matplotlib.pyplot as plt
import time
from mpi4py import MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

def main():
    if rank == 0:
        print(time.time())
        directory_hodsmith = '/home/shivani.shah/shahlabtools/Python/hod_new/hod'
        
        path_to_gal_dir = directory_hodsmith + '/output/800/run2_linkinglengths/0p3mps/cat_snapshot_observed.hdf5'
        hodDict = readFile(path_to_gal_dir)
        path_to_halo_dir = '/home/shivani.shah/Projects/LIGO/runs/Round6/run2_linkinglengths/0p3mps/output'
        simCat = readSimCat(path_to_halo_dir)
        print("Collected everything")
    else:
        hodDict = None
        simCat = None
    comm.Barrier()
    hodDict = comm.bcast(hodDict, root = 0)
    simCat = comm.bcast(simCat, root = 0)
    nhalos = len(simCat.GroupMass)
    perrank = nhalos//size
    haloIndices = np.arange(rank*perrank, (rank+1)*perrank)
    GalPos, GalVel, GalAbsMag, SubhaloMass, HaloInd, HaloID, HaloPos, HaloVel, HaloMass, removeGals, removeSubs = createNewCat(hodDict, simCat, haloIndices)
    comm.Barrier()

    print("Obtained everything from all ranks")
    #GalPos = np.concatenate(np.array(comm.gather(GalPos, root = 0)))
    GalPos = np.array(comm.gather(GalPos, root = 0))
    GalVel = np.array(comm.gather(GalVel, root = 0))
    GalAbsMag = np.array(comm.gather(GalAbsMag, root = 0))
    SubhaloMass = np.array(comm.gather(SubhaloMass, root = 0))
    HaloID = np.array(comm.gather(HaloID, root = 0))
    HaloInd = np.array(comm.gather(HaloInd, root = 0))
    HaloPos = np.array(comm.gather(HaloPos, root = 0))
    HaloVel = np.array(comm.gather(HaloVel, root = 0))
    HaloMass = np.array(comm.gather(HaloMass, root = 0))
    #HaloCM = np.concatenate(np.array(comm.gather(HaloCM, root = 0)))
    removeGals = np.array(comm.gather(removeGals, root = 0))
    removeSubs = np.array(comm.gather(removeSubs, root = 0))
    
    if rank == 0:
        GalPos = np.concatenate(GalPos)
        GalVel = np.concatenate(GalVel)
        GalAbsMag = np.concatenate(GalAbsMag)
        SubhaloMass = np.concatenate(SubhaloMass)
        HaloInd = np.concatenate(HaloInd)
        HaloID = np.concatenate(HaloID)
        HaloPos = np.concatenate(HaloPos)
        HaloVel = np.concatenate(HaloVel)
        HaloMass = np.concatenate(HaloMass)
        removeGals = np.concatenate(removeGals)
        removeSubs = np.concatenate(removeSubs)

        remaining = nhalos%size
        haloIndices = np.arange(size*perrank, (size*perrank) + remaining)
        gp, gv, gm, sm, hi, hI, hp, hv, hm, rg, rs = createNewCat(hodDict, simCat, 
                                                              haloIndices)
        GalPos = np.append(GalPos, gp, axis = 0)
        print(np.shape(GalPos))
        GalVel = np.append(GalVel, gv, axis = 0)
        print(np.shape(GalVel))
        GalAbsMag = np.append(GalAbsMag, gm)
        print(np.shape(GalAbsMag))
        SubhaloMass = np.append(SubhaloMass, sm)
        print(np.shape(SubhaloMass))
        HaloInd = np.append(HaloInd, hi)
        print(np.shape(HaloInd))
        HaloID = np.append(HaloID, hI)
        print(np.shape(HaloID))
        HaloPos = np.append(HaloPos, hp, axis = 0)
        print(np.shape(HaloPos))
        HaloVel = np.append(HaloVel, hv, axis = 0)
        print(np.shape(HaloVel))
        HaloMass = np.append(HaloMass, hm)
        print(np.shape(HaloMass))
        #HaloCM = np.append(HaloCM, hc, axis = 0)
        removeGals = np.append(removeGals, rg)
        print(np.shape(removeGals))
        removeSubs = np.append(removeSubs, rs)
        print(np.shape(removeSubs))
        

        newCat = dict(GalPos = GalPos,GalVel = GalVel, GalAbsMag = GalAbsMag, 
                  HaloInd = HaloInd, HaloMass = HaloMass, 
                      SubhaloMass = SubhaloMass, HaloPos = HaloPos, 
                      HaloVel = HaloVel,
                      removeGals = removeGals, HaloID = HaloID)#, removeSubs = removeSubs)


        
        
        filePath = "../data/800/run2_linkinglengths/0p3mps/mock_cat.hdf5"
        writeFile(newCat, filePath)
        
        

def createNewCat(hodDict, simCat, haloIndices):
    ngalaxies = np.sum(simCat.GroupNsubs[haloIndices])
    perrank = len(haloIndices)
    GalPos = np.full((ngalaxies, 3), -1.)
    GalVel = np.full((ngalaxies, 3), -1.)
    GalAbsMag = np.full(ngalaxies, -1.)
    SubhaloMass = np.full(ngalaxies, -1.)
    HaloInd = np.full(ngalaxies, -1)
    HaloID = np.full(perrank, -1)
    HaloMass = np.full(perrank, -1.)
    HaloPos = np.full((perrank, 3), -1.)
    HaloVel = np.full((perrank, 3), -1.)
    #HaloCM = np.full((ngalaxies,3), -1)
    #newCat = dict(pos = pos, vel = vel, abs_mag = abs_mag, 
    #              haloInd = haloInd, haloMass = haloMass, 
    #              mass = mass, haloPos = haloPos, haloVel = haloVel, 
    #              haloCM = haloCM)
    
   
    removeGals = np.empty(perrank)
    removeSubs = np.empty(perrank)
    nStart = 0
    nhaloCount = 0
    time_ar = []
    
    for j in range(perrank):
        startTime = time.time();
        haloIndex = haloIndices[j]
        whereGals = np.where(np.array(hodDict["halo_ind"]) == haloIndex)[0]
        #nGals = len(whereGals)
        whereSubs = np.where(np.array(simCat.SubhaloGrNr) == haloIndex)[0]
        #nSubs = len(whereSubs)

        absmagGals = np.array(hodDict["abs_mag"])[whereGals]
        wneg = ~np.isnan(absmagGals)
        whereGals = whereGals[wneg]
        absmagGals = absmagGals[wneg]
        whereGals = whereGals[np.argsort(absmagGals)]
        massSubs = simCat.SubhaloMass[whereSubs]
        whereSubs = whereSubs[np.flip(np.argsort(massSubs))]

        nGals = len(whereGals)
        nSubs = len(whereSubs)

        
        if nGals < nSubs:
            ###removeSubs.append(nSubs - nGals)
            #removeSubs[j] = nSubs - nGals
            #removeGals[j] = 0.
            


        if nGals > nSubs:
            ####removeGals.append(nGals - nSubs)
            removeGals[j] = nGals - nSubs
            removeSubs[j] = 0.
        if nGals == nSubs:
            removeGals[j] = 0.
            removeSubs[j] = 0.

        if (nGals == 0) or (nSubs == 0):
            HaloID[j] = haloIndex
            HaloMass[j] = simCat.GroupMass[haloIndex]
            HaloPos[j] = simCat.GroupPos[haloIndex]
            HaloVel[j] = simCat.GroupVel[haloIndex]
            continue

        '''
        absmagGals = np.array(hodDict["abs_mag"])[whereGals]
        wneg = ~np.isnan(absmagGals)
        whereGals = whereGals[wneg]
        absmagGals = absmagGals[wneg]
        whereGals = whereGals[np.argsort(absmagGals)]
        massSubs = simCat.SubhaloMass[whereSubs]
        whereSubs = whereSubs[np.flip(np.argsort(massSubs))]
        '''
        nNewGals = np.min([nGals, nSubs])
        whereGals = whereGals[:nNewGals]
        whereSubs = whereSubs[:nNewGals]
        nEnd = nStart + nNewGals
        GalPos[nStart:nEnd] = simCat.SubhaloPos[whereSubs]
        GalVel[nStart:nEnd] = simCat.SubhaloVel[whereSubs]
        GalAbsMag[nStart:nEnd] = hodDict["abs_mag"][whereGals]
        SubhaloMass[nStart:nEnd] = simCat.SubhaloMass[whereSubs]
        HaloInd[nStart:nEnd] = np.full(nNewGals, haloIndex)
        HaloID[j] = haloIndex
        HaloMass[j] = simCat.GroupMass[haloIndex]
        #HaloCM[haloIndex] = simCat.GroupCM[haloIndex]
        HaloPos[j] = simCat.GroupPos[haloIndex]
        HaloVel[j] = simCat.GroupVel[haloIndex]

        #update the starting point
        nStart = nEnd
        timenow = time.time() - startTime
        time_ar.append(timenow)
        if rank == 0:
            print("Time remaining %d", np.mean(time_ar)*(perrank - j)/3600.)
            print("---")
        
    
    #getting rid of extra galaxies 
    GalPos = GalPos[:nEnd]
    GalVel = GalVel[:nEnd]
    GalAbsMag = GalAbsMag[:nEnd]
    SubhaloMass = SubhaloMass[:nEnd]
    HaloInd = HaloInd[:nEnd]

    
    print(np.shape(GalPos))
    return GalPos, GalVel, GalAbsMag, SubhaloMass, HaloInd, HaloID, HaloPos, HaloVel, HaloMass,removeGals, removeSubs


def readFile(path):
    f = h5py.File(path)
    keys = f.keys()
    hodDict = {}
    for j in range(len(keys)):
        hodDict[keys[j]] = f[keys[j]][:]

    f.close()

    return hodDict


def readSimCat(path_to_file):
    #snaps = glob.glob(path_to_file + '/snapdir*')
    #s = len(snaps) - 1
    s = 4
    cat = readsubf.subfind_catalog(path_to_file, s, 
                                   subcat=True, grpcat=True, 
                                   keysel=['SubhaloVel',
                                           'SubhaloPos',
                                           'SubhaloGrNr',
                                           'GroupNsubs',
                                           'GroupFirstSub',
                                           'SubhaloMass', 
                                           'GroupMass',
                                           'GroupVel', 
                                           'GroupPos'])

    return cat



def writeFile(dictionary, path):
    f = h5py.File(path, "a")
    s = f.create_group("sim1")
    for key in dictionary:
        key = s.create_dataset(key, data = dictionary[key])

    f.close()

if __name__ == "__main__":
    main()
