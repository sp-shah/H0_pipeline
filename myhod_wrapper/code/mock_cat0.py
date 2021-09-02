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
import matplotlib.pyplot as plt
import time
from mpi4py import MPI
from scipy.interpolate import interp1d
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()


'''

def main():
    if rank == 0:
        print(time.time())
        directory_hodsmith = '/home/shivani.shah/shahlabtools/Python/hod_new/hod'
        
        path_to_gal_dir = directory_hodsmith + '/output/1600/cat_snapshot_observed.hdf5'
        hodDict = readFile(path_to_gal_dir)
        hodDict["SubhaloMass"] = np.full(hodDict["halo_ind"], -1.)
        
        path_to_halo_dir = '/home/shivani.shah/Projects/LIGO/runs/Round8/run1/output'
        simCat = readSimCat(path_to_halo_dir)
        print("Collected everything")
    else:
        hodDict = None
        simCat = None
    comm.Barrier()

    hodDict = comm.bcast(hodDict, root = 0)
    simCat = comm.bcast(simCat, root = 0)
    nHalos = len(np.unique(hodDict["halo_ind"]))
    perrank = nHalos//size
    haloIndicesAll = np.unique(hodDict["halo_ind"])
    #haloIndices = np.arange(perrank*rank, perrank*(rank+1), 1)
    haloIndices = haloIndicesAll[rank*perrank:(rank+1)*perrank]
    #newDict = modifyCat(hodDict, simCat, haloIndices)
    pos, vel = modifyCat(hodDict, simCat, haloIndices)
    comm.Barrier()
    if rank == 0:
        print("Done first collection")

    pos = np.array(comm.gather(pos, root =0))
    vel = np.array(comm.gather(vel, root = 0))
    

    # for key in newDict:
    #     newDict[key] = np.array(comm.gather(newDict[key], root = 0))
    
    
    #if rank == 0:
    #    for key in newDict:
    #        newDict[key] = np.concatenate(newDict[key])
            
    if rank == 0:
        pos = np.concatenate(pos)
        vel = np.concatenate(vel)
        #remaining = nHalos%size
        #haloIndices = np.arange(size*perrank, (size*perrank) + remaining)
        haloIndices = haloIndicesAll[size*perrank:]
        p, v = modifyCat(hodDict, simCat, haloIndices)
        #for key in newDict:
        #    newDict[key] = np.append(newDict[key], lastDict[key], axis = 0)
        pos = np.append(pos, p, axis = 0)
        vel = np.append(vel, v, axis = 0)
        

        finalDict = dict(GalPos=pos, GalVel = vel, HaloInd = hodDict["halo_ind"],GalAbsMag = hodDict["abs_mag"])
        
        filePath = "../data/1600/mock_cat0.hdf5"
        writeFile(finalDict, filePath)
        

        

def modifyCat(hodDict, simCat, haloIndices):
    ngalaxies = len(hodDict["abs_mag"])
    HaloInd = np.full(ngalaxies, -1.)
    perrank = len(haloIndices)
    HaloID = np.full(perrank, -1)
    HaloMass = np.full(perrank, -1.)
    HaloPos = np.full((perrank, 3), -1.)
    HaloVel = np.full((perrank,3), -1.)
    HaloNGals = np.full(perrank, -1)
    time_ar = []

    #haloCount = 0
    for j in range(len(haloIndices)):
        startTime = time.time()
        haloInd = haloIndices[j]
        whereGals = np.where(hodDict["halo_ind"] == haloInd)[0]
        whereSubs = np.where(simCat.SubhaloGrNr == haloInd)[0]
        
        absmagGals = np.array(hodDict["abs_mag"])[whereGals]
        wneg = ~np.isnan(absmagGals)
        whereGals = whereGals[wneg]
        absmagGals = absmagGals[wneg]
        whereGals = whereGals[np.argsort(absmagGals)]
        massSubs = simCat.SubhaloMass[whereSubs]
        whereSubs = whereSubs[np.flip(np.argsort(massSubs))]


        nGals = len(whereGals)
        nSubs = len(whereSubs)
        
        if nGals == nSubs:
            newPos = simCat.SubhaloPos[whereSubs]
            newVel = simCat.SubhaloVel[whereSubs]
            SubhaloMass = simCat.SubhaloMass[whereSubs]
            HaloID[haloCount] = haloInd
            HaloMass[j] = simCat.GroupMass[haloInd]
            HaloPos[j] = simCat.GroupPos[haloInd]
            HaloVel[j] = simCat.GroupVel[haloInd]
            
            hodDict["pos"][whereGals] = newPos
            hodDict["vel"][whereGals] = newVel
            hodDict["SubhaloMass"][whereGals] = SubhaloMass

        if nGals > nSubs:
             #nChange = nGals - nSubs
             whereGalsMod = whereGals[:nSubs]
             whereGal0 = whereGals[nSubs:]
             newPos = simCat.SubhaloPos[whereSubs]
             newVel = simCat.SubhaloVel[whereSubs]
             SubhaloMass = simCat.SubhaloMass[whereSubs]
             hodDict["pos"][whereGalsMod] = newPos
             hodDict["vel"][whereGalsMod] = newVel
             hodDict["SubhaloMass"][whereGalsMod] = SubhaloMass
             hodDict["vel"][whereGal0] = np.full((len(whereGal0), 3), 0.)
             
             HaloID[haloCount] = haloInd
             HaloMass[j] = simCat.GroupMass[haloInd]
             HaloPos[j] = simCat.GroupPos[haloInd]
             HaloVel[j] = simCat.GroupVel[haloInd]


        if nGals < nSubs:
            #nChange = nSubs - nGals
            whereSubs = whereSubs[:nGals]
            newPos = simCat.SubhaloPos[whereSubs]
            newVel = simCat.SubhaloVel[whereSubs]
            SubhaloMass = simCat.SubhaloMass[whereSubs]
            hodDict["pos"][whereGals] = newPos
            hodDict["vel"][whereGals] = newVel
            hodDict["SubhaloMass"][]
            
            

        #update the starting point
        timenow = time.time() - startTime
        time_ar.append(timenow)
        if rank == 0:
            print("Time remaining %d", np.mean(time_ar)*(perrank - j)/3600.)
            print("---")
            
            
    return hodDict["pos"], hodDict["vel"]
        
    
'''





def main():
    if rank == 0:
        print(time.time())
        directory_hodsmith = '/home/shivani.shah/shahlabtools/Python/hod_new/hod'
        
        path_to_gal_dir = directory_hodsmith + '/output/1600/run1/cat_snapshot_observed.hdf5'
        hodDict = readFile(path_to_gal_dir)
        path_to_halo_dir = '/home/shivani.shah/Projects/LIGO/runs/Round8/run1/output'
        simCat = readSimCat(path_to_halo_dir)
        print("Collected everything")
    else:
        hodDict = None
        simCat = None
    comm.Barrier()
    hodDict = comm.bcast(hodDict, root = 0)
    simCat = comm.bcast(simCat, root = 0)
    #creating the stellar halo mass function
    subhaloMass = simCat.SubhaloMass
    minSubMass = np.log10(np.min(subhaloMass)); maxSubMass = np.log10(np.max(subhaloMass))
    subhaloMass = np.logspace(minSubMass, maxSubMass, 100000)
    f = shm(subhaloMass)
    haloIndicesAll = np.unique(hodDict["halo_ind"])
    nHalos = len(haloIndicesAll)
    perrank = nHalos//size
    haloIndices = haloIndicesAll[rank*perrank:(rank+1)*perrank]
    #haloIndices = np.arange(rank*perrank, (rank+1)*perrank)
    GalPos, GalVel, GalAbsMag, SubhaloMass, HaloInd, HaloID, HaloPos, HaloVel, HaloMass = createNewCat(hodDict, simCat, haloIndices, f)
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
    #removeGals = np.array(comm.gather(removeGals, root = 0))
    #removeSubs = np.array(comm.gather(removeSubs, root = 0))
    
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
        #removeGals = np.concatenate(removeGals)
        #removeSubs = np.concatenate(removeSubs)

        #remaining = nhalos%size
        #haloIndices = np.arange(size*perrank, (size*perrank) + remaining)
        haloIndices = haloIndicesAll[size*perrank:]
        print(len(haloIndices))
        gp, gv, gm, sm, hi, hI, hp, hv, hm = createNewCat(hodDict, simCat, 
                                                          haloIndices, f)
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
        #removeGals = np.append(removeGals, rg)
        #print(np.shape(removeGals))
        #removeSubs = np.append(removeSubs, rs)
        #print(np.shape(removeSubs))
        

        newCat = dict(GalPos = GalPos,GalVel = GalVel, GalAbsMag = GalAbsMag, 
                  HaloInd = HaloInd, HaloMass = HaloMass, 
                      SubhaloMass = SubhaloMass, HaloPos = HaloPos, 
                      HaloVel = HaloVel,
                      HaloID = HaloID)#, removeSubs = removeSubs)


        
        
        filePath = "../data/1600/run1/mock_cat0_test.hdf5"
        writeFile(newCat, filePath)
        
        

def createNewCat(hodDict, simCat, haloIndices, f):
    #print(rank, "Entered function")
    ngalaxies = len(hodDict["halo_ind"])
    perrank = len(haloIndices)
    GalPos = np.full((ngalaxies, 3), -1.)
    GalVel = np.full((ngalaxies, 3), -1.)
    GalAbsMag = np.full(ngalaxies, -1.)
    SubhaloMass = np.full(ngalaxies, -1.)
    HaloInd = np.full(ngalaxies, -1.)
    HaloID = np.full(perrank, -1.)
    HaloMass = np.full(perrank, -1.)
    HaloPos = np.full((perrank, 3), -1.)
    HaloVel = np.full((perrank, 3), -1.)
    #HaloCM = np.full((ngalaxies,3), -1)
    #newCat = dict(pos = pos, vel = vel, abs_mag = abs_mag, 
    #              haloInd = haloInd, haloMass = haloMass, 
    #              mass = mass, haloPos = haloPos, haloVel = haloVel, 
    #              haloCM = haloCM)
    
   
    #removeGals = np.empty(perrank)
    #removeSubs = np.empty(perrank)
    nStart = 0
    #nhaloCount = 0
    time_ar = []
    
    for j in range(perrank):
        #print(rank, j)
        startTime = time.time();
        haloIndex = haloIndices[j]
        whereGals = np.where(np.array(hodDict["halo_ind"]) == haloIndex)[0]
        whereSubs = np.where(np.array(simCat.SubhaloGrNr) == haloIndex)[0]
    

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
            nEnd = nStart + nGals
            whereSubs = whereSubs[:nGals]
            
            newPos = simCat.SubhaloPos[whereSubs]
            newVel = simCat.SubhaloVel[whereSubs]
            GalPos[nStart:nEnd] = newPos
            GalVel[nStart:nEnd] = newVel
            GalAbsMag[nStart:nEnd] = hodDict["abs_mag"][whereGals]
            SubhaloMass[nStart:nEnd] = simCat.SubhaloMass[whereSubs]
            HaloInd[nStart:nEnd] = np.full(nGals, haloIndex)

            HaloID[j] = haloIndex
            HaloMass[j] = simCat.GroupMass[haloIndex]
            HaloPos[j] = simCat.GroupPos[haloIndex]
            HaloVel[j] = simCat.GroupVel[haloIndex]
            
            nStart = nEnd
            #print(nEnd)
            

        if nGals > nSubs:
           
            nEnd1 = nStart + nSubs
            nEnd = nStart + nGals
            newPos = simCat.SubhaloPos[whereSubs]
            newVel = simCat.SubhaloVel[whereSubs]
            
            GalPos[nStart:nEnd1] = newPos
            excessPos = hodDict["pos"][whereGals][nSubs:] #using HOD assigned positions
            GalPos[nEnd1:nEnd] = excessPos
            GalVel[nStart:nEnd1] = newVel
            #------------------------------------------------------
            nExcess = nGals - nSubs
            if True:
                vx = newVel[:,0]; vy = newVel[:,1]; vz = newVel[:, 2]
                velxMean = np.mean(vx); velyMean = np.mean(vy); velzMean = np.mean(vz)
                velxStd = np.std(vx); velyStd = np.std(vy); velzStd = np.std(vz)
                vxNew = np.random.normal(loc = velxMean, scale = velxStd, size = nExcess)
                vyNew = np.random.normal(loc = velyMean, scale = velyStd, size = nExcess)
                vzNew = np.random.normal(loc = velzMean, scale = velzStd, size = nExcess)
                excessVel = np.array(np.transpose([vxNew, vyNew, vzNew]))
                excessX = excessPos[:,0]; excessY = excessPos[:,1]; excessZ = excessPos[:,2] 
                excessD = np.sqrt(excessX**2 + excessY**2 + excessZ**2)
                c = 2.99e5 #km/s
                excessHubbleV = 100.*excessD #km/s
                z = excessHubbleV/c
                model = ezgal.model('bc03_ssp_z_0.02_salp.model')
                model.add_filter("sloan_r")
                stellarMass = model.get_masses(3.0, zs = z, nfilters = 1) #solar units 
                excessSubhaloMass = f(stellarMass) #solar units
                excessSubhaloMass /= 1.e10 #sim units

            else:
                vx = newVel[:,0]; vy = newVel[:,1]; vz = newVel[:, 2]
                velxMean = 0.; velyMean = 0.; velzMean = 0.
                velxStd = np.std(vx); velyStd = np.std(vy); velzStd = np.std(vz)
                vxNew = np.random.normal(loc = velxMean, scale = velxStd, size = nExcess)
                vyNew = np.random.normal(loc = velyMean, scale = velyStd, size = nExcess)
                vzNew = np.random.normal(loc = velzMean, scale = velzStd, size = nExcess)
                excessVel = np.array(np.transpose([vxNew, vyNew, vzNew]))

            #-----------------------------------------------------------
            #GalVel[nEnd1:nEnd] = np.full((nGals-nSubs, 3), 0.)
            GalVel[nEnd1:nEnd] = excessVel
            SubhaloMass[nStart:nEnd1] = simCat.SubhaloMass[whereSubs]
            SubhaloMass[nEnd1:nEnd] = np.full(nGals-nSubs, -1.)
            GalAbsMag[nStart:nEnd] = hodDict["abs_mag"][whereGals]
            HaloInd[nStart:nEnd] = np.full(nGals, haloIndex)

            HaloID[j] = haloIndex
            HaloMass[j] = simCat.GroupMass[haloIndex]
            HaloPos[j] = simCat.GroupPos[haloIndex]
            HaloVel[j] = simCat.GroupVel[haloIndex]
        
            
            nStart = nEnd
            #print(nEnd)

        if nGals == nSubs:
            nEnd = nStart + nGals
            newPos = simCat.SubhaloPos[whereSubs]
            newVel = simCat.SubhaloVel[whereSubs]
            GalPos[nStart:nEnd] = newPos
            GalVel[nStart:nEnd] = newVel
            GalAbsMag[nStart:nEnd] = hodDict["abs_mag"][whereGals] 
            SubhaloMass[nStart:nEnd] = simCat.SubhaloMass[whereSubs]
            HaloInd[nStart:nEnd] = np.full(nGals, haloIndex)

            HaloID[j] = haloIndex
            HaloMass[j] = simCat.GroupMass[haloIndex]
            HaloPos[j] = simCat.GroupPos[haloIndex]
            HaloVel[j] = simCat.GroupVel[haloIndex]
            
            nStart = nEnd
            #print(nEnd)
        



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
    return GalPos, GalVel, GalAbsMag, SubhaloMass, HaloInd, HaloID, HaloPos, HaloVel, HaloMass


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


def shm(subhaloMass):
    #source: https://iopscience.iop.org/article/10.1088/0004-637X/710/2/903/pdf
    #equation 2, table 1
    subhaloMass *= 1.e10 #converting back from the sim units to just solar units
    normalization = 0.02828
    beta = 1.057
    M_char = 10**(11.884)
    gamma = 0.556
    stellarMass = 2*subhaloMass*normalization*((subhaloMass/M_char)**-beta + (subhaloMass/M_char)**gamma)**(-1)
    f = interp1d(stellarMass, subhaloMass, fill_value = np.nan, bounds_error = False) #in solar mass units

    return f



def writeFile(dictionary, path):
    f = h5py.File(path, "a")
    s = f.create_group("sim1")
    for key in dictionary:
        key = s.create_dataset(key, data = dictionary[key])

    f.close()

if __name__ == "__main__":
    main()
