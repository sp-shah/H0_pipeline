import numpy as np
import matplotlib.pyplot as plt
import ezgal
import h5py
import sys
from matplotlib import rc
from matplotlib.ticker import (MultipleLocator, FormatStrFormatter,
                               AutoMinorLocator)



rc("text", usetex = True)
rc("text.latex", unicode = True)
rc("font", size = 16., family = "serif")


c = 2.99e5
H0 = 100.
KsThresh = 11.25
h = 0.72
boxVol = 500. * 500. * 500.


def main(targetFilePath, mockPaths):
    
    #magThresh()
    #lumfuncHist(targetFilePath, mockPaths)
    sample90(targetFilePath, mockPaths)


def sample90(targetFilePath, mockPath):
     #----------obtain the target Cumulative lum func---------
    dat = np.genfromtxt(targetFilePath, names = ("mag", "phi"))
    magTarget = dat["mag"] + 0.134
    phiTarget = dat["phi"]
    phiTarget = 10**phiTarget
    bins = np.arange(-23.5, -9.5, 0.005)
    binsPlot = np.arange(-23.5, -9.5, 0.5)
    binValuesTarget = np.empty(len(bins) - 1, dtype = np.float)
    binValuesTargetPlot = np.empty(len(binsPlot)-1, dtype = np.float)
    for k in range(len(bins)-1):
        edge1 = np.where(np.abs((magTarget - bins[k])) < 1.e-3)[0]
        #print(edge1)
       
        edge2 = np.where(np.abs(magTarget - bins[k+1]) < 1.e-3)[0]
        #print(edge2)
       

        if (len(edge1)>0) & (len(edge2) > 0):
            edge1 = np.min(edge1)
            edge2 = np.min(edge2)
            phiEdge1 = phiTarget[edge1]
            phiEdge2 = phiTarget[edge2]
            binValuesTarget[k] = (phiEdge2 - phiEdge1)*boxVol
        else:
            binValuesTarget[k] = 0.

    for q in range(len(binsPlot)-1):
        edge1 = np.where(np.abs((magTarget - binsPlot[q])) < 1.e-3)[0]
        #print(edge1)
       
        edge2 = np.where(np.abs(magTarget - binsPlot[q+1]) < 1.e-3)[0]
        #print(edge2)
       

        if (len(edge1)>0) & (len(edge2) > 0):
            edge1 = np.min(edge1)
            edge2 = np.min(edge2)
            phiEdge1 = phiTarget[edge1]
            phiEdge2 = phiTarget[edge2]
            binValuesTargetPlot[q] = (phiEdge2 - phiEdge1)*boxVol
        else:
            binValuesTargetPlot[q] = 0.


    magMock = readFile(mockPath)
    fig, ax = plt.subplots()
    binValuesMockPlot, _, _ = ax.hist(magMock, bins = binsPlot, color = "black", alpha = 0.1, edgecolor = "black")
    binValuesMock, _ = np.histogram(magMock, bins = bins)
    ax.plot(binsPlot[:-1] + 0.25, binValuesTargetPlot, color = "black", alpha = 0.7)
    #ax.plot(bins[:-1] + 0.25, binValuesMock, color = "black")
    ax.set_yscale("log")
    ax.invert_xaxis()
    #ax.set_xlabel("Mr")
    #ax.set_ylabel("Number of galaxies")
    
    mag90 = recursiveSearch(bins, binValuesTarget, binValuesMock)
    print(mag90)
    axYlim = ax.get_ylim()
    #ax2 = ax.twiny()
    yax = np.logspace(0., np.log10(axYlim[1]), 50)
    xax = np.full(len(yax), mag90)
    ax.plot(xax, yax, linestyle = "--", color = "k")
    plt.show()


    Mr, d = magThresh()
    ind90 = np.where(np.abs(Mr-mag90) < 0.01)
    print(d[ind90])


    #--------------------------------
    #distMagComplete(bins, binValuesTarget, binValuesMock)
    


def recursiveSearch(bins, binValuesTarget, binValuesMock):
    mag90 = []
    for j in range(len(bins) - 1):
        binInd = j+1 #starting from the left edge of brightest bin
        #print(bins[binInd])
        targetNum = np.sum(binValuesTarget[:binInd])
        mockNum = np.sum(binValuesMock[:binInd])
        #print(mockNum/targetNum)
        if (np.abs(mockNum/targetNum - 0.87) < 0.0001):
            print(np.abs(mockNum/targetNum))
            mag90.append(bins[binInd])
            #break
        #print("------")
    
    print(mag90)
    return np.max(mag90)




def distMagComplete(bins, binValuesTarget, binValuesMock):
    Mr, d = magThresh()
    ratio = np.empty(len(bins)-1)
    distanceCut = np.empty(len(bins) - 1)
    for j in range(len(bins)-1):
        binInd = j+1 
        targetNum = np.sum(binValuesTarget[:binInd])
        mockNum = np.sum(binValuesMock[:binInd])
        ratio[j] = mockNum/targetNum
        indMatch = np.where(np.abs(Mr-bins[binInd]) < 0.01)[0]
        if len(indMatch) == 1:
            distanceCut[j] = d[indMatch]
        
    
    fig, ax = plt.subplots()
    ax.plot(bins[1:], ratio*100.)
    #ax.set_xticks([-23., -22., -21., -20., -19., -18., -17., -16., -15.])
    #plt.minorticks_on()
    #ax.tick_params(axis = "x", which = "minor", bottom = False, top = False)
    ax.yaxis.set_minor_locator(MultipleLocator(10))
    ax2 = ax.twiny()
    ax2.set_xlim(ax.get_xlim())
    ax.set_xlabel(r"$\mathrm{M_r}$")
    ax.set_ylabel(r"Percent Complete")
    
    dPlaceHolders = [10, 20, 30, 40, 50]#, 60, 100,500]
    MrPlaceHolders = np.empty(len(dPlaceHolders))
    for i in range(len(dPlaceHolders)):
        ind = np.where(np.abs(d - dPlaceHolders[i]) < 0.01)[0]
        MrPlaceHolders[i] = Mr[ind]
    


    newlabel = np.array(dPlaceHolders)/10
    newPos = MrPlaceHolders
    ax2.set_xticklabels(newlabel)
    ax2.set_xticks(newPos) 
    ax2.set_xlabel("Distance/10 [Mpc]")
    #ax.set_xticks(newPos)
    #ax.set_xticklabels(newPos)

    
    
    plt.savefig("../plots/distMagComplete.png", bbox_inches = "tight")
    plt.show()







def lumfuncHist(targetFilePath, mockPaths):
    
    #----------obtain the target Cumulative lum func---------
    dat = np.genfromtxt(targetFilePath, names = ("mag", "phi"))
    magTarget = dat["mag"] + 0.134
    phiTarget = dat["phi"]
    phiTarget = 10**phiTarget
    bins = np.arange(-23.5, -9.5, 0.5)
    print(bins)
    binValuesTarget = np.empty(len(bins) - 1, dtype = np.float)
    for k in range(len(bins)-1):
        edge1 = np.where(np.abs((magTarget - bins[k])) < 1.e-3)[0]
        #print(edge1)
       
        edge2 = np.where(np.abs(magTarget - bins[k+1]) < 1.e-3)[0]
        #print(edge2)
       

        if (len(edge1)>0) & (len(edge2) > 0):
            edge1 = np.min(edge1)
            edge2 = np.min(edge2)
            phiEdge1 = phiTarget[edge1]
            phiEdge2 = phiTarget[edge2]
            binValuesTarget[k] = (phiEdge2 - phiEdge1)*boxVol
        else:
            binValuesTarget[k] = 0.

    
    fig, axAr = plt.subplots(2,2, figsize = (18, 15))
    j = 0
   
    #-----------------
    for m in range(2):
        for n in range(2):
            magMock = readFile(mockPaths[j])
            #print(np.min(magMock), np.max(magMock))
            #print(len(magMock))
            
            #bins = np.arange(-23.5, -9.5, 0.5)
            ax = axAr[m,n]
            #plt.figure()
            #ax, figure = plt.add_subplots(111)
            binValuesMock, bins, _ = ax.hist(magMock, bins = bins, color = "black", alpha = 0.1, edgecolor = "black")
            #binValuesMock, bins, _ = plt.hist(magMock, bins, color = "black", alpha = 0.1, edgecolor = "black")
            #plt.show()
            #ax = plt.gca()
            ax.invert_xaxis()
            
            ax.plot(bins[:-1] + 0.25, binValuesTarget, marker = "s", color = "black", alpha = 0.7)
            ax.set_yscale("log")
            #ax.set_xlabel("Mr")
            #ax.set_ylabel("Number of galaxies")
            
            
            axYlim = ax.get_ylim()
            ax2 = ax.twiny()
            yax = np.logspace(0., np.log10(axYlim[1]), 50)
        
            
            Mr, d = magThresh()
            dPlaceHolders = [10, 20, 30, 40, 50, 60, 100,500]
            MrPlaceHolders = np.empty(len(dPlaceHolders))
            for i in range(len(dPlaceHolders)):
                ind = np.where(d == dPlaceHolders[i])[0]
                MrPlaceHolders[i] = Mr[ind]
                if (dPlaceHolders[i] == 50) or (dPlaceHolders[i] == 100):
                    continue
                else:
                    xax = np.full(len(yax), Mr[ind])
                    ax.plot(xax, yax, linestyle = "-", color = "k")

            newpos = MrPlaceHolders
            newlabel = ["1", "2", "3", "4", "", "6","", "50"]
            if m == 0:
                ax2.set_xticklabels(newlabel)
            if m == 1:
                ax2.set_xticklabels([])
            ax2.set_xticks(newpos)            
            #ax2.set_xlabel("Distance/10 [Mpc]")
            ax2.set_xlim(ax.get_xlim())
            #print(MrPlaceHolders)
            

            #-----------Missing Number of Galaxies--------------------
            total = 0 
            binInd = np.where(np.abs(bins - MrPlaceHolders[0]) < 0.5)[0][0]
            print(binInd)
            print(bins[binInd])
            print(binValuesTarget[binInd])
            binValuesTargetUse = binValuesTarget[:binInd]
            binValuesMockUse = binValuesMock[:binInd]

            diff = binValuesTarget - binValuesMock
            totalTarget = np.sum(binValuesTarget)
            #print(totalTarget)
            total = np.sum(diff)
            totalStr = '%.2E' % total
            totalMock = np.sum(binValuesMock)
            #print(totalMock)
            percentComplete = totalMock*100./totalTarget
            percentStr = r'%.2f'%percentComplete + '\\%'
            #ax.text(-21.5, 5.e6, totalStr)
            ax.text(-21.5, 2.e6, percentStr, color = "tomato")

            
            diff = binValuesTargetUse - binValuesMockUse
            totalTargetUse = np.sum(binValuesTargetUse)
            #print(totalTargetUse)
            total = np.sum(diff)
            totalStr = '%.2E' % total
            totalMockUse = np.sum(binValuesMockUse)
            #print(totalMockUse)
            percentComplete = totalMockUse*100./totalTargetUse
            percentStr = r'%.2f'%percentComplete + '\\%'
            #ax.text(-21.5, 5.e5, totalStr)
            ax.text(-21.5, 2.e5, percentStr, color = "tomato")
            #sys.exit()


       
            j += 1

    
    fig.add_subplot(111, frameon = False)
    plt.tick_params(labelcolor='none', top=False, bottom=False, left=False, right=False)
    plt.xlabel(r"$\mathrm{M_r}$")
    plt.ylabel(r"Number of Galaxies")
    AX = plt.gca()
    AX2 = AX.twiny()
    AX2.set_xlabel(r"Distance/10 [Mpc]")
    AX2.tick_params(labelcolor = "none", top=False, bottom=False, left=False, right=False)
    AX2.spines["top"].set_visible(False)
    AX2.spines["right"].set_visible(False)
    AX2.spines["left"].set_visible(False)
    AX2.spines["bottom"].set_visible(False)
    
    
    plt.savefig("../plots/sampleCompleteTest1600FoF.png", bbox_inches = "tight")
    plt.show()
        

    


def magThresh():

    d = np.arange(5., 505., 0.1)
    z = H0*h*d/c
    #z = np.arange(0, 0.2, 0.001)
    #D = z*c/(H0) #h ^ -1 [Mpc]
    #d = D/h
    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r = model.get_observed_absolute_mags(3.0, filters = "sloan_r", zs = z, ab = True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters = "ks", zs = z, vega = True)
    rminusk = abs_mag_r - abs_mag_ks
    
    #plt.plot(z,rminusk)
    #plt.show()

    rThresh = rminusk + KsThresh
    Mr = rThresh - 25. - 5.*np.log10(d)
    
    #rThreshMax = np.max(rminusk) + KThresh
    #rThreshMin = np.min(rminusk) + 
    
    return Mr, d



    



def readFile(path):
    f = h5py.File(path, "r")
    keys = np.array(f.keys())
    print(keys)
    if "sim1" in f.keys():
        g = f["sim1"]
        mag = g["GalAbsMag"][:]
        mag = mag[~np.isnan(mag)]
        return mag
    else:
        print("here")
        mag = f["abs_mag"][:]
        mag = mag[~np.isnan(mag)]
        return mag



def discardedGal(pathFid, path0p3mps):

    absMagFid = readFile(pathFid)
    absMag0p3mps = readFile(path0p3mps)
    wFid = np.where(np.isnan(absMagFid))[0]
    w0p3mps = np.where(np.isnan(absMag0p3mps))[0]
    print(len(wFid))
    print(len(w0p3mps))


if __name__ == "__main__":
    
    targetFilePath = "../data/target_lf.dat"
    pathTo800After = "../data/800/mock_cat_debuged.hdf5"
    pathTo800Before = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/800/cat_snapshot_observed.hdf5"
    pathTo16000p3mpsAfter = "../data/1600/run2_linkinglengths/0p3mps/mock_cat.hdf5"
    pathTo16000p3mpsBefore = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/1600/run2_linkinglengths/0p3mps/cat_snapshot_observed.hdf5"
    pathTo1600After = "../data/1600/mock_cat.hdf5"
    pathTo1600Before = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/1600/cat_snapshot_observed.hdf5"
    paths = [pathTo1600Before, pathTo16000p3mpsBefore, pathTo1600After, pathTo16000p3mpsAfter]
    #main(targetFilePath, paths)
    main(targetFilePath, pathTo1600Before)
    pathTo1600After = "../data/1600/mock_cat.hdf5"
    pathTo1600Before = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/1600/cat_snapshot_observed.hdf5"


    #discardedGal(pathTo1600Before, pathTo16000p3mpsBefore)
