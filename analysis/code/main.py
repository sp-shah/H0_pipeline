import numpy as np
import sys
import funcdef as fd
import random


def main():
    
    
    pathBase = "/home/shivani.shah/Projects/LIGO/analysis/mock/analysis/data/1600/"
    pathToGrpCat = pathBase + "run1/groupedGal85.hdf5"
    #pathToGrpCat = pathBase + "run2_linkinglengths/0p3mps/groupedGal85.hdf5"
    pathToNewCat = pathBase + "run1/unwrapedCatBin.hdf5"
    #pathToNewCat = pathBase + "run2_linkinglengths/0p3mps/unwrapedCatBin.hdf5"
    #------------------------------------
    
    '''
    groupCat = fd.readFile(pathToGrpCat)
    groupCatUnwraped = fd.unwrapCat(groupCat)
    fd.writeFile(groupCatUnwraped, pathToNewCat)
    sys.exit()
    '''
    
    #-----------------------------------
      

   
    grpCat = fd.readFile(pathToNewCat)
    #fd.ratiosDist(grpCat)
    fd.massDist(grpCat)
    #fd.randomPicksGroupMem(grpCat)
    sys.exit()
    #fd.digging(grpCat)
    #fd.randomPicksGroupMem(grpCat)
    #fd.randomPicksVelDisp(grpCat)
    #fd.randomPickGroupMemBinned(grpCat)
    






    
    #obtain the galaxies that belong to the groups with membership 
    #between the selected range
    #galDict = fd.selectedData(galDict, membershipUp, membershipDown)
    
    #randomly pick a galaxy that lies within some
    #range properties
    

   
    #in case we want to compute the boundness of all the valid galaxies:
    #correspondingGroupInd = galDictp["groupNr"][:]

    #obtain the potential of the group
    #boundFrac, unboundFrac = fd.boundness(galDict, correspondingGroupInd)

    #print(boundFrac, unboundFrac)




    #compute the potential energy of the galaxy 

    #compute the kinetic energy of the galaxy -- how? use pec vel?

    #determine if its bound or not 
    
    #spit out a peculiar velocity measurement along with standard deviation

    #compare to true peculiar velocity of the galaxy



if __name__ == "__main__":
    main()
