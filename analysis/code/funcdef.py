import numpy as np
import matplotlib.pyplot as plt
import h5py
import random
from scipy.interpolate import interp1d
from matplotlib import rc
import sys


rc("text", usetex = True)
rc("text.latex", unicode = True)
rc("font", size = 16., family = "serif")


def readFile(path):
    f = h5py.File(path)
    keys = f.keys()
    print(keys)
    dictionary = {}
    for key in keys:
        dictionary[key] = f[key][:]

    f.close()
    return dictionary


def writeFile(cat, path):
    f = h5py.File(path)
    for key, value in cat.items():
        print(key)
        d = f.create_dataset(key, data = value)
    f.close()




def countMem(haloInd):
    

    groupMem = np.full(np.max(haloInd)+1, -1)
    haloIndices = np.unique(haloInd)
    
    for k in haloIndices:
        wHalo = np.where(haloInd == k)[0]
        groupMem[k] = len(wHalo)
        

    return groupMem



def unwrapCat(groupCat):
    #create new arrays for group and halo Id
    #identifying only groups of 3
    #create a new array for group mass, halo mass
    #create a new array for matching halo Ind

    groupId = groupCat["groupId"]
    #obtaining the number of members 
    #of the group given by the index of the 
    #array
    groupMem = countMem(groupId)

    #the new groupId array considers groups with 
    #3 or more members as groups
    groupIdNew = np.full(len(groupId), -1)
    grpCount = 0
    grpId = np.where(groupMem > 1)[0]
    #removing the groupId = 0, which is for singles
    grpId = grpId[grpId != 0]
    print(len(grpId))

    #assigning new groupIds to the galaxies 
    #from 0 to (number of groups)-1
    for j in grpId:
        w = np.where(groupId == j)[0]
        groupIdNew[w] = grpCount 
        grpCount += 1
    
    #sanity check
    print(len(np.unique(groupIdNew)))
    print(np.max(groupIdNew), np.min(groupIdNew))
    print("------------")


    haloInd = groupCat["HaloInd"].astype("int")
    haloMem = countMem(haloInd)
    HaloIndNew = np.full(len(haloInd), -1)
    haloCount = 0
    #wHalo = np.where(haloMem > 2)[0]
    wHalo = np.where(haloMem > 1)[0]
    print(len(wHalo))
    for j in wHalo:
        w = np.where(haloInd == j)[0]
        HaloIndNew[w] = haloCount
        haloCount += 1

    print(np.max(HaloIndNew))

    groupCat["groupIdF"] = groupIdNew
    groupCat["HaloIdF"] = HaloIndNew
    groupMass,groupMem = calcMass(groupCat["groupIdF"], groupCat["SubhaloMass"])
    HaloMass, HaloMem = calcMass(groupCat["HaloIdF"], groupCat["SubhaloMass"])
    matchingHaloInd = linkingGrps(groupCat)
    groupCat["groupMem"] = groupMem
    groupCat["groupMass"] = groupMass
    groupCat["matchingHaloInd"] = matchingHaloInd
    groupCat["HaloMass"] = HaloMass
    groupCat["HaloMem"] = HaloMem
    nCompAr, nInterAr = ratios(groupCat)
    #print(len(nCompAr[~np.isnan(nCompAr)]))
    #print(np.mean(nCompAr[~np.isnan(nCompAr)]))
    #print(np.mean(nInterAr[~np.isnan(nInterAr)]))
    groupCat["nCompAr"] = nCompAr
    groupCat["nInterAr"] = nInterAr
    

    #Fraction of galaxies grouped
    grouped = len(np.where(groupCat["HaloIdF"] != -1)[0])
    total = len(groupCat["HaloIdF"])
    print(np.float(grouped)/np.float(total))
    sys.exit()
    return groupCat


def calcMass(Id, SubhaloMass):
    
    Ids = np.unique(Id)
    Ids = Ids[Ids != -1]
    
    groupMass = np.full(len(Ids), np.nan)
    groupMem = np.full(len(Ids), -1)
    for j in Ids:
        w = np.where(Id == j)[0]
        mass = np.sum(SubhaloMass[w])
        groupMass[j] = mass
        groupMem[j] = len(w)
        

    groupMass = groupMass*1.e10 #solar units
    return groupMass, groupMem



def linkingGrps(groupCat):
    groupId = groupCat["groupIdF"]
    HaloInd = groupCat["HaloIdF"]
    SubhaloMass = groupCat["SubhaloMass"]

    groupIdU = np.unique(groupId)
    groupIdU = groupIdU[groupIdU != -1]
    HaloIndU = np.unique(HaloInd)
    HaloIndU = HaloIndU[HaloIndU != -1]

    #matching haloInd for a group given by
    #index of the array
    matchingHaloInd = np.full(len(groupIdU), -1)
    matchingGrpInd = np.full(len(HaloIndU), -1)
    for k in range(len(groupIdU)):
        grpId = groupIdU[k]
        wGal = np.where(groupId == grpId)[0]
        if len(wGal) < 3:
            print("Mistake")
        SubMass = SubhaloMass[wGal]
        order = np.flip(np.argsort(SubMass))
        wGal = wGal[order]
        corrHaloInd = HaloInd[wGal]
        haloIndCandidates = np.unique(corrHaloInd)
        
        if len(haloIndCandidates) == 1:
            if haloIndCandidates[0] == -1: 
                continue
            else:
                winningHaloInd = haloIndCandidates[0]
                matchingHaloInd[k] = winningHaloInd
                continue

        haloScore = np.empty(len(haloIndCandidates))
        for i in range(len(haloIndCandidates)):
            halothis = haloIndCandidates[i]
            whalo = np.where(corrHaloInd == halothis)[0]
            rankAr = whalo + 1
            scoreAr = 1./(rankAr)**2
            haloScore[i] = np.sum(scoreAr)
        
        winningHaloInd = haloIndCandidates[haloScore == np.max(haloScore)]
        matchingHaloInd[k] = winningHaloInd[0]


    return matchingHaloInd



def ratios(grpCat):
    groupId = grpCat["groupIdF"]
    HaloId = grpCat["HaloIdF"]
    matchingHaloInd = grpCat["matchingHaloInd"]
    
    groupIdU = np.unique(groupId)
    groupIdU = groupIdU[groupIdU != -1]
    print(len(groupIdU))
    print(len(matchingHaloInd))
    HaloIdU = np.unique(HaloId)
    
    nInterAr = np.full(len(groupIdU), np.nan)
    nCompAr = np.full(len(groupIdU), np.nan)

    for j in groupIdU:
        grpId = j
        wGal = np.where(groupId == grpId)[0]
        haloThis = HaloId[wGal]
        haloTrue = matchingHaloInd[grpId]
        if haloTrue == -1:
            continue
        nTrue = len(np.where(HaloId == haloTrue)[0])
        nComp = len(np.where(haloThis == haloTrue)[0])
        nInter = len(haloThis) - nComp
        nCompAr[j] = np.float(nComp)/np.float(nTrue)
        nInterAr[j] = np.float(nInter)/np.float(nTrue)


    return nCompAr, nInterAr



def ratiosDist(grpCat):
    nComp = grpCat["nCompAr"]
    nInter = grpCat["nInterAr"]
    nComp = nComp[~np.isnan(nComp)]
    nInter = nInter[~np.isnan(nInter)]
    #-----------------------------
    print(np.mean(nComp))
    print(np.mean(nInter))
    #------------------
    matchingHaloInd = grpCat["matchingHaloInd"]
    wField = np.where(matchingHaloInd == -1)[0]
    print(len(wField))

    fig, ax = plt.subplots()
    ax.hist(nComp, log = True, color = "tab:grey", bins = 30)
    ax.set_xlabel("Completion Fraction")
    ax.set_ylabel("Number of Groups")
    plt.show()

    
    fig, ax = plt.subplots()
    ax.hist(nInter, log = True, color = "tab:grey", bins = 30)
    ax.set_xlabel("Interloper Fraction")
    ax.set_ylabel("Number of Groups")
    plt.show()


def massDist(grpCat):
    
    #---------------
    groupMass = grpCat["groupMass"]
    matchingHaloInd = grpCat["matchingHaloInd"]
    HaloMass = grpCat["HaloMass"]
    HaloMem = grpCat["HaloMem"]
    #print(np.min(groupMass), np.max(groupMass))
    massBins = np.array([11,12,13,14,15,16])
    massBins = 10**massBins
    
    
    fig, ax = plt.subplots()
    
    ax.hist(HaloMass, bins = massBins, fill = 1, log = True, label = "FoF Catalog")
    ax.hist(groupMass, bins = massBins, color = "tab:grey", log = True, fill = 0, label = "Mock Crook Cat")
    ax.set_xscale("log")
    ax.set_ylabel("Number of Groups")
    ax.set_xlabel(r"$\mathrm{Group\ Mass\ [M_\odot]}$")
    #plt.savefig("../plots/1600/run1/massDist.png", bbox_inches = "tight")
    plt.show()
    sys.exit()
    

    nField = np.full(len(massBins)-1, 0.)
    nCompBins = np.full(len(massBins)-1, 0.)
    nInterBins = np.full(len(massBins)-1, 0.)
    binsComp = np.arange(0,1.1, 0.1)
    binsInter = np.arange(0.,6.,0.25)
    binsMem = np.arange(0,250, 10)

    for j in range(1):
        j = 4
        nUp = 2.e3
        wBin = np.where((massBins[j] <= groupMass) & (groupMass < massBins[j+1]))[0]
        print(len(wBin))
        nComp = grpCat["nCompAr"][wBin]
        nInter = grpCat["nInterAr"][wBin]
        groupMem = grpCat["groupMem"][wBin]
        #groupMem = groupMem[~np.isnan(nComp)]
        nField[j] = np.float(len(nComp[np.isnan(nComp)]))/np.float(len(wBin))
        nGrouped = 1. - nField[j]
        nComp = nComp[~np.isnan(nComp)]
        nInter = nInter[~np.isnan(nInter)]
        nCompBins[j] = np.mean(nComp)
        nInterBins[j] = np.mean(nInter)
        matchingHaloIndices = matchingHaloInd[wBin]
        matchingHaloIndices = matchingHaloIndices[matchingHaloIndices != -1]

        '''
        fig, [ax1,ax2] = plt.subplots(1,2, figsize = (9,5))
        ax1.hist(nComp, color = "tab:grey", bins = binsComp)
        ax2.hist(nInter, color = "tab:grey", bins = binsInter)
        ax1.set_title(np.str(len(nComp)))
        plt.show()
        '''

        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2,2, figsize = (15,10))
        ax1.hist(groupMem, color = "tab:grey",  fill = 0, hatch = "/", log = True,
                 bins = binsMem)#, bins = [3,4,5,6,7,8,9,10],)
        ax1.set_title(r"Test Group Membership Distribution")
        ax1.set_xlabel(r"Number of Members")
        ax1.set_ylabel(r"Number of Groups")
        ax1.set_ylim((0.5, nUp))
        ax1.set_xlim((-10,250))
        ax1.text(200, 1.e3, "%.2f" % round(nGrouped*100., 2) + "\\%")

        ax2.hist(HaloMass[matchingHaloIndices], bins = 10**np.array([11,12,13,14,15,16]), color = "tab:grey",
                 fill = 0, hatch = "/", log = True)
        ax2.set_xscale("log")
        ax2.set_xlabel(r"Group Mass [$\mathrm{M_\odot}$]")
        ax2.set_ylabel(r"Number of Groups")
        ax2.set_title(r"True Group Mass Distribution")
        ax2.set_ylim((0.5, nUp))
        
        ax3.hist(HaloMem[matchingHaloIndices], color = "tab:grey", fill = 0, hatch = "/", log = True,
                 bins = binsMem)
        ax3.set_xlabel(r"Number of Members")
        ax3.set_ylabel(r"Number of Groups")
        ax3.set_title(r"True Group Membership Distribution")
        ax3.set_ylim((0.5, nUp))
        ax3.set_xlim((-10,250))
      
        
        
       
        ax4.hist(nComp, color = "tab:grey", bins = binsComp, label = "Completion Mean = " + np.str("%.2f"% round(np.mean(nComp), 2)), log = True)
        ax4.hist(nInter, fill = 0, hatch = "/", bins = binsInter,
                 label = "Interloper Mean = " + np.str("%.2f"% round(np.mean(nInter), 2)))
        ax4.legend()
        ax4.set_xlabel(r"Fraction")
        ax4.set_ylabel(r"Number of Groups")
        ax4.set_ylim((0.5, nUp))
        
        fig.suptitle(r"$\mathrm{10^{15}\ M_\odot\ <=\ Group\ Mass\ <\ 10^{16}}$")
        plt.subplots_adjust(hspace = 0.45)
        plt.savefig("../plots/1600/run1/massBin5.png", bbox_inches = "tight")
        plt.show()
        

    
    print(nField)
    print(nCompBins)
    print(nInterBins)
    







'''
def selectedData(galDict, membershipUp, membershipDown):
    groupCount = np.copy(galDict["groupMem"])
    groupNr = np.copy(galDict["groupId"])
    relevantGroups = np.where((groupCount <= membershipUp) & (groupCount >= membershipDown))[0]
    boolSelected = np.zeros(len(groupNr))
    for j in range(len(relevantGroups)):
        selectedInd = np.where(groupNr == relevantGroups[j])
        boolSelected[selectedInd] = True

    newGalDict = {}
    for key in galDict:
        newGalDict[key] = galDict[key][boolSelected]

    return newGalDict
'''

def shm(subhaloMass):
    # working in solar mass units 
    #source: https://iopscience.iop.org/article/10.1088/0004-637X/710/2/903/pdf
    #equation 2, table 1
    subhaloMass *= 1.e10
    normalization = 0.02828
    beta = 1.057
    M_char = 10**(11.884)
    gamma = 0.556
    stellar_mass = 2*subhaloMass*normalization*((subhaloMass/M_char)**-beta + (subhaloMass/M_char)**gamma)**(-1)
    #log_stellar_mass = np.log10(stellar_mass)
    return stellar_mass



def stellar_mass_cdf(galDict):
    subhaloMass = np.copy(galDict["SubhaloMass"])
    #get rid of this once the subhalomass is fixed !!!!!!!!!!!!!!!!!
    subhaloMass = subhaloMass[subhaloMass != -1.]
    stellarMass = shm(subhaloMass)
    x = np.arange(0., len(stellarMass), 1.)
    #from most massive to least --> don't think it matters which way
    #to make sure that other datasets are accordingly ordered
    indOrder = np.flip(np.argsort(stellarMass))
    stellarMass = stellarMass[indOrder] 
    #y will range from 0 to 1, allowing a convenient random picking
    y = np.cumsum(stellarMass)/np.sum(stellarMass)
    #print(np.min(y), np.max(y))
    f = interp1d(y, x)

    return f, np.min(y), np.max(y), indOrder






def randomPickGroupMemBinned(memDict):
     
    #obtain HaloID, their respective masses 
    #create halo mass bins
    #collect halos that fall into those bins
    #for each bin, collect all the galaxies and create a sample
    #obtain the probability for that sample
    
    samplePts = 30
    bins = np.array([12,13,14,15,16])
    bins = 10**bins
    print(bins)
    solarMass = 1.98e10
    bins = bins/solarMass
    print(bins)
    positiveCar = np.empty(len(bins)-1)
    #sys.exit()
    f,yLo, yUp, indOrder = stellar_mass_cdf(memDict)
    #convert the bins to the right units 
    for j in range(len(bins)-1):
        print(j)
        count = 0 
        positiveC = 0 
      
        while count < samplePts:
            randomPick = np.random.uniform(yLo, yUp)
            indPick = np.int(round(f(randomPick)))
            groupId = memDict["groupId"][indPick]
            if groupId == 0:
                continue
            wMem = np.where(memDict["groupId"] == groupId)[0]
            if len(wMem) >= 3:
                
                totMass = np.sum(memDict["SubhaloMass"][wMem])
                #print(totMass)
                if totMass  < bins[j+1] and totMass > bins[j]:
                    if j == 0: 
                        print("")
                        #print(len(wMem))
                        #print(groupId)
                    count += 1
                    HaloInd = memDict["HaloInd"][indPick]
                    trueHaloInd = memDict["matchingHaloInd"][groupId]
                    if HaloInd == trueHaloInd: 
                        positiveC += 1
                    
            positiveCar[j] = positiveC
            
    print(positiveCar)/30.

def randomPicksGroupMem(grpCat):
    
    nSample = 10000
    count = 0
    countMass = np.full(nSample, -1.)
    positiveC = 0
    positiveCMass = []
    nField = 0
    f,yLo, yUp, indOrder = stellar_mass_cdf(grpCat)
    SubhaloMass = grpCat["SubhaloMass"]


    while count < nSample:
        randomPick = np.random.uniform(yLo, yUp)
        indPick = np.int(round(f(randomPick)))
        groupId = grpCat["groupIdF"][indPick]
    
        if groupId == -1:
            #count += 1
            #nField += 1
            continue
       
            
        trueHaloInd = grpCat["matchingHaloInd"][groupId]
        if trueHaloInd == -1:
            countMass[count] = grpCat["groupMass"][groupId]
            count += 1
            
        else:
            HaloInd = grpCat["HaloIdF"][indPick]
            if HaloInd == trueHaloInd: 
                positiveC += 1
                positiveCMass.append(grpCat["groupMass"][groupId])
            countMass[count] = grpCat["groupMass"][groupId]
            count += 1
            
    print(count)
    nGroup = count - nField
    print(nGroup*100./count)
    print(positiveC)
    print(positiveC*100./nGroup)
    

    cVal, _, _ = plt.hist(countMass, bins = 10**np.array([11,12,13,14,15,16]), 
             color = "tab:grey", label = "All Samples")
    plt.xscale("log")
    plt.ylim((-200,5000))
    pVal, _, _ = plt.hist(positiveCMass, bins = 10**np.array([11,12,13,14,15,16]),
             fill = 0, label = "Positively Grouped")
    plt.xlabel(r"$\mathrm{Group\ Mass\ M_\odot}$")
    plt.ylabel(r"$\mathrm{Number of Galaxies}$")
    plt.title(r"Probability of Positive Grouping")
    #plt.hist(grpCat["groupMass"], fill = 0, bins = 10**np.array([11,12,13,14,15,16]))
    probBins = pVal*100./cVal
    plt.text(1.5e11, 300, "%.2f" % round(probBins[0], 2) +"\\%")
    plt.text(1.5e12, 700, "%.2f" % round(probBins[1], 2) +"\\%")
    plt.text(1.5e13, 3500, "%.2f" % round(probBins[2], 2) +"\\%")
    plt.text(1.5e14, 3500, "%.2f" % round(probBins[3], 2) + "\\%")
    plt.text(1.5e15, 2000, "%.2f" % round(probBins[4], 2) + "\\%")
    print(probBins)
    plt.savefig("../plots/1600/run1/probMassBin.png", bbox_inches = "tight")
    plt.show()




def randomPicksVelDisp(memDict):
    
    samplePts = 10000
    countFoF = 0
    countPerc = 0
    delVelFoFAr = np.full(samplePts, -1.)
    delVelpercAr = np.full(samplePts, -1.)
    f,yLo, yUp, indOrder = stellar_mass_cdf(memDict)
    SubhaloMass = memDict["SubhaloMass"]
    #get rid of this for the new catalog
    print(len(np.where(SubhaloMass == -1)[0]))
    booleanSubhalo = np.where(SubhaloMass != -1)[0]
    Except = ["groupMem", "matchingHaloInd"]
    for key in memDict:
        if key in Except:
            continue
        else:
            print(key)
            memDict[key] = memDict[key][booleanSubhalo]
            memDict[key] = memDict[key][indOrder]
    
    while countFoF < samplePts:
        randomPick = np.random.uniform(yLo, yUp)
        indPick = np.int(round(f(randomPick)))
        delVelFoF = delFoF(memDict, indPick)
        if delVelFoF == -1.:
            continue
        else:
            delVelFoFAr[countFoF] = delVelFoF
            countFoF += 1
    
    print("done FoF")

    while countPerc < samplePts:
        randomPick = np.random.uniform(yLo, yUp)
        indPick = np.int(round(f(randomPick)))
        delVelperc = delperc(memDict, indPick)
        if delVelperc == -1:
            continue
        else:
            delVelpercAr[countPerc] = delVelperc
            countPerc += 1


    print(np.mean(delVelFoFAr))
    print(np.std(delVelFoFAr))
    print(np.mean(delVelpercAr))
    print(np.std(delVelpercAr))

    binsMin = np.min([np.min(delVelFoFAr), np.min(delVelpercAr)])
    binsMax = np.max([np.max(delVelFoFAr), np.max(delVelFoFAr)])
    bins = np.arange(binsMin, binsMax, 1000)
    fig, ax = plt.subplots()
    ax.hist(delVelFoFAr, bins = 50, color = "tab:grey", 
            label = "True Catalog (FoF)", log = True)
    ax.hist(delVelpercAr, bins = 50, fill = 0, hatch = "/", color = "k",
            label = "Test Catalog (Crook)", log = True)
    ax.set_ylabel(r"Galaxy Sample Points")
    ax.set_xlabel(r"$\mathrm{\Delta V_{los}\ km/s}$")
    ax.set_title(r"$\mathrm{3 < Membership}$")
    plt.legend()
    plt.savefig("../plots/velDisp.png", bbox_inches = "tight")
    plt.show()


def delFoF(memDict, indPick):
    
    targetVel = memDict["GalHvel"][indPick]
    #targetVel = memDict["hvel"][indPick]
    targetHaloInd = memDict["HaloInd"][indPick]
    #where do target's co-members reside
    targetMemInd = np.where(memDict["HaloInd"] == targetHaloInd)[0]
    if len(targetMemInd) < 3: #or len(targetMemInd) > 15:
        return -1

    
    targetMemVel = memDict["GalHvel"][targetMemInd]
    #targetMemVel = memDict["hvel"][targetMemInd]
    groupVel = np.mean(targetMemVel)
    delVel = groupVel - targetVel

    return delVel
    
    


def delperc(memDict, indPick):

    targetVel = memDict["GalHvel"][indPick]
    #targetVel = memDict["hvel"][indPick]
    targetGrpInd = memDict["groupId"][indPick]
    #where does the target reside
    targetMemInd = np.where(memDict["groupId"] == targetGrpInd)[0]
    if len(targetMemInd) < 3: #or len(targetMemInd) > 15:
        return -1

    
    targetMemVel = memDict["GalHvel"][targetMemInd]
    #targetMemVel = memDict["hvel"][targetMemInd]
    groupVel = np.mean(targetMemVel)
    delVel = np.float(groupVel) - np.float(targetVel)

    return delVel
    



def digging(memDict):

    #true group
    HaloInd = memDict["HaloInd"]
    haloID = np.unique(HaloInd)
    haloMem = np.full(len(haloID), -1)
    for j in range(len(haloID)):
        wmem = np.where(HaloInd == haloID[j])[0]
        haloMem[j] = len(wmem)

    nField = 0
    for i in range(len(haloMem)):
        if haloMem[j] < 3:
            nField += haloMem[j]

    print("Total number of galaxies")
    print(len(memDict["groupId"]))

    print("Number of Field Galaxies")
    print(nField)

    wGrps = np.where(haloMem >= 3)[0]
    print("Number of True Groups")
    print(len(wGrps))
        

    groupId = memDict["groupId"]
    groupIdAr = np.unique(groupId)
    groupMem = np.full(len(groupIdAr), -1)
    for k in range(len(groupMem)):
        wMem = np.where(groupId == groupIdAr[k])[0]
        groupMem[k] = len(wMem)

    #the singles belonging to the group 0
    nFieldTest = groupMem[0]
    for m in range(1, len(groupMem)):
        if groupMem[m] < 3:
            nFieldTest += groupMem[m]
    
    print("Number of Fields in Test")
    print(nFieldTest)

    wGrps = np.where(groupMem[1:] >= 3)[0]
    print("Number of Test Groups")
    print(len(wGrps))
