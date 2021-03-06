import numpy as np
import h5py
from mpi4py import MPI
from collections import Counter
import matplotlib.pyplot as plt
import sys

comm = MPI.COMM_WORLD
rank = comm.Get_rank() #use 128?
size = comm.Get_size()


def main():

    if rank == 0:
       
        #pathTocat = "/home/shivani.shah/Projects/LIGO/analysis/mock/pickFoF/data/1600/run2_linkinglengths/0p3mps/groupedGal85.hdf5"
        pathTocat = "/home/shivani.shah/Projects/LIGO/analysis/mock/pickFoF/data/1600/run1/groupedGal85.hdf5"
        groupCat = readFile(pathTocat)
        
    else:
        #fofCat = None
        groupCat = None

    comm.Barrier()
    #fofCat = comm.bcast(fofCat, root = 0)
    groupCat = comm.bcast(groupCat, root = 0)
    
    nGroupsTot = np.max(groupCat["groupId"]) #GroupInd = 0 is for single 
    perrank = nGroupsTot//size
    groupIndices = np.arange(perrank*rank, perrank*(rank + 1))

    #groupIndices = np.unique(groupCat["groupId"])
    #indSingles = np.where(groupIndices == 0)[0]
    #groupIndices = np.delete(groupIndices, indSingles)
    #-------------------------------------------------------
    matchingHaloInd, nComp, nInter, groupMass = findMatchingHalo(groupCat,groupIndices)
    if rank == 0:
        matchingHaloInd = np.array(comm.gather(matchingHaloInd, root = 0))
        nComp = np.array(comm.gather(nComp, root = 0))
        nInter = np.array(comm.gather(nInter, root = 0))
        groupMass = np.array(comm.gather(groupMass, root = 0))

        matchingHaloInd = np.concatenate(matchingHaloInd)
        nComp = np.concatenate(nComp)
        nInter = np.concatenate(nInter)
        groupMass = np.concatenate(groupMass)

        groupIndices = np.arange(perrank*(size), nGroupsTot) 
        m, nc, ni, gm = findMatchingHalo(groupCat, groupIndices)

        matchingHaloInd = np.append(matchingHaloInd, m)
        #testing duplicates
        testAr = matchingHaloInd[matchingHaloInd != -1]
        counter = Counter(testAr)
        for key, value in counter.items():
            if value > 1:
                print("duplicate")
                print(key)
                print(value)
                print("-------------------")
        nComp = np.append(nComp, nc)
        nInter = np.append(nInter, ni)
        groupMass = np.append(groupMass, gm)

        #do I need matchingHaloInd?
        nComp = nComp[~np.isnan(nComp)]
        nInter = nInter[~np.isnan(nInter)]
        print(len(nComp))
        
        plt.hist(nComp)
        plt.show()
        plt.hist(nInter)
        plt.show()
        
        print(np.mean(nComp))
        print(np.max(nComp))
        print(np.min(nComp))
        print(np.mean(nInter))
        print(np.min(nInter))
        print(np.max(nInter))
        
        sys.exit()

        #pathToFullCat = "/home/shivani.shah/Projects/LIGO/analysis/mock/analysis/data/1600/run2_linkinglengths/0p3mps/trueMemGalCat.hdf5"
        pathToFullCat = "/home/shivani.shah/Projects/LIGO/analysis/mock/analysis/data/1600/run1/trueMemGalCat.hdf5"
        writeFile(pathToFullCat, groupCat, matchingHaloInd, groupMass)


def findMatchingHalo(groupCat, groupIndices):
    nGroups = len(groupIndices)
    matchingHaloInd = np.full(nGroups, -1)
    nComp = np.full(nGroups, np.nan)
    nInter = np.full(nGroups, np.nan)
    groupMass = np.full(nGroups, np.nan)
    countField = 0

    
    #starting the for loop from 1 since we don't care about 
    #the groupId = 0 which is singles --> change this to a better format!!!
    for j in range(1, nGroups):
        groupInd = groupIndices[j]
        wGal = np.where(groupCat["groupId"] == groupInd)[0]
        if len(wGal) < 3:
            continue
        corrHaloInd = groupCat["HaloInd"][wGal]
        corrHaloInd = corrHaloInd.astype("int")
        galAbsMag = groupCat["GalAbsMag"][wGal]
        SubhaloMass = groupCat["SubhaloMass"][wGal] #or stellar mass if we have it
        nGal = len(wGal)
        groupMass[j] = np.sum(SubhaloMass)

        #Can rank based on mass or absMag
        #Adding weights to the galaxy
        order = np.flip(np.argsort(SubhaloMass)) #highest mass to lowest
        corrHaloInd = corrHaloInd[order]
        #order = np.argsort(galAbsMag)
        #corrHaloInd = corrHaloInd[order]

        haloIndCandidates = np.unique(corrHaloInd)

            
        haloScore = np.empty(len(haloIndCandidates))
        for i in range(len(haloIndCandidates)):
            halothis = haloIndCandidates[i]
            whalo = np.where(corrHaloInd == halothis)[0]
            rankAr = whalo + 1
            scoreAr = 1./(rankAr)**2
            haloScore[i] = np.sum(scoreAr)
        
        
        for k in range(len(haloIndCandidates)):
            whalo = np.where(groupCat["HaloInd"] == haloIndCandidates[k])[0]
            if len(whalo) < 3:
                haloScore[k] = np.nan
            
        haloIndCandidates = haloIndCandidates[~np.isnan(haloScore)]
        haloScore = haloScore[~np.isnan(haloScore)]
       
       
        if len(haloScore) > 0:
            winningHaloInd = haloIndCandidates[haloScore == np.max(haloScore)]
            matchingHaloInd[j] = winningHaloInd[0]
        else:
            #consider that this group has only true field galaxies
            countField += 1
            continue

        #galaxies common to winning halo and this group (ncorrect)
        nCorrect = len(np.where(corrHaloInd == winningHaloInd)[0])
        nTrue = len(np.where(groupCat["HaloInd"] == winningHaloInd)[0])
        nComp[j] = np.float(nCorrect)/np.float(nTrue)
        
        nForeign = len(np.where(corrHaloInd != winningHaloInd)[0])
        nInter[j] = np.float(nForeign)/np.float(nTrue)

    
    return matchingHaloInd, nComp, nInter, groupMass



def readFile(path):
    f = h5py.File(path, "r")
    keys = f.keys()
    groupCat = {}
    for key in keys:
        groupCat[key] = f[key][:]

    
    f.close()
    return groupCat


def writeFile(pathToFullCat, cat, matchingHaloInd):
    f = h5py.File(pathToFullCat, "w")
    for key in cat:
        d = f.create_dataset(key, data = cat[key])
    
    d = f.create_dataset("matchingHaloInd", data = matchingHaloInd)
    f.close()
        


if __name__ == "__main__":
    main()
