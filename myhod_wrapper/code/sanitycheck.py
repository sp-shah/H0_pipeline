import numpy as np
import matplotlib
#matplotlib.use("agg")
import matplotlib.pyplot as plt
import h5py 
import sys
import matplotlib as mpl
from matplotlib import rc
from scipy import interpolate
import ezgal
from scipy.spatial import KDTree
import ezgal
import glob
import simread.readsubfHDF5 as readsubf



mpl.rcParams['agg.path.chunksize'] = 10000
rc('text', usetex=True) 
rc("text.latex", unicode = True)
rc("font", size =16., family = 'serif')


def lumfunc(path_to_targetlf, paths):

    #source for k-correction: currently value = 0.134

    #obtaining the data for the target luminosity function
    dat = np.genfromtxt(path_to_targetlf, names = ("mag", "phi"))
    mag = dat["mag"]
    phi = dat["phi"]
    

    #sdss blanton lum func
    path_to_blanton = "../data/sdss_cumulative_lf.dat"
    dat  =  np.genfromtxt(path_to_blanton, names = ("mag", "phi"))
    magB = dat["mag"]
    phiB = dat["phi"]
    
    #setting the plot and the targetlf
    fig3, ax3 = plt.subplots()
    ax3.plot(mag + 0.134, 10**phi, label = "Target Luminosity Function,\ z=0.1", color = 'black')
    #ax3.plot(magB, 10**phiB, label = "Blanton", color = "gold")
    ax3.set_ylabel(r"$\mathrm{Cumulative\ Lum\ Func}$")
    ax3.set_xlabel(r"$\mathrm{M_r}$")
    #ax3.set_title(r"$\mathrm{M_r < -20., r < 20., z = 0.0}$")
    #ax3.set_ylim([5.e-8,0.5])
    #ax3.set_xlim([-14,-23])
    ax3.invert_xaxis()
    ax3.set_yscale("log")
    line18 = np.full(len(phi), -18.)
    ax3.plot(line18, 10**phi, linestyle = "--", color = 'black')
    

    labels = [r"$800^3$ Before", r"$800^3$ After", r"$1600^3$ Before", r"$1600^3$ After"]
    #labels = ["1600", "800"]
    colors = ["darkgreen", "mediumseagreen", "crimson", "lightpink"]

    for i in range(len(paths)):
        #obtaining the 800 run
        f = h5py.File(paths[i])
        if i == 1 or i == 3:
            g = f["sim1"]
            #sys.exit()
            abs_mag = g["GalAbsMag"][:]
            abs_mag = abs_mag[~np.isnan(abs_mag)]
            plt.hist(abs_mag)
            plt.show()
            
            minabsmag = np.min(abs_mag)
            print("----------")
            print("After Cat")
            print("Max magnitude " + np.str(np.max(abs_mag)))
            w = np.where(abs_mag > -10.)
            print(len(w))
            w = np.where(abs_mag > -20.)
            print(len(w))
            #halo_mass = g["HaloMass"][:]
        else:
            #g = f["sim1"]
            #print(f.keys())
            #print(g.keys())
            #sys.exit()
            abs_mag = f["abs_mag"][:]
            #abs_mag = g["abs_mag"][:]
            abs_mag = abs_mag[~np.isnan(abs_mag)]
            #plt.hist(abs_mag)
            #plt.show()
        
            minabsmag = np.min(abs_mag)
            print("----------")
            print("Before Cat")
            print("Max magnitude " + np.str(np.max(abs_mag)))
            w = np.where(abs_mag > -10.)
            print(len(w))
            w = np.where(abs_mag > -20.)
            print(len(w))
            #halo_mass = f["halo_mass"][:]
            
        f.close()
        #continue
        #-------------
        '''
        bin_values, bin_edges = np.histogram(abs_mag,mag)
        bin_values = bin_values/np.diff(bin_edges)
        cumsum = np.cumsum(bin_values)
        #cumsum =cumsum/np.log10(np.diff(bin_edges))
        #slope = np.zeros(len(cumsum) -1, dtype = np.float)
        #slope = np.zeros(len(bin_values)-1, dtype = np.float)
        
        #for j in range(len(bin_values)-1):
        #    slope[j] = (bin_values[j+1] - bin_values[j])/(bin_edges[j+1] - bin_edges[j])
       #     slope[j] = (cumsum[j+1]-cumsum[j])/(bin_edges[j+1] - bin_edges[j])

        simulation_volume = 500.*500.*500.
        phi_calc = cumsum/simulation_volume
        print(phi_calc)
        phi_iget = lumfunc_blanton(bin_edges[:-2])
        '''
        #---------------------------------

        binAr = np.arange(np.min(mag), np.max(mag), 0.001)
        bin_values, bin_edges = np.histogram(abs_mag, bins = binAr)
        bin_values = bin_values#/0.001
        appMagLim = 20.
        distMod = appMagLim - bin_edges
        limitingDist = 10**((distMod - 25.)/5.)
        volMag = (4./3.)*np.pi*limitingDist**3
        volBox = 500.* 500.* 500.
        nL = np.cumsum(bin_values) #/ np.diff(bin_edges)
        phiL_calc = nL/volMag[:-1]  #/volMag[:-1]  #volBox #/
        #phiL_calc = np.cumsum(phiL_calc)
        phiL_blanton = lumfunc_blanton(bin_edges)

    
        ax3.plot(bin_edges[:-1], phiL_calc, label = labels[i], color = colors[i])
    #ax3.plot(bin_edges, np.cumsum(phiL_blanton), label = "blanton")

    


   
    plt.legend()
    #plt.savefig("../plots/lumfunc_rezTest.png", bbox_inches = "tight")
    plt.show()
  


def lumfunc_blanton(abs_mag):
    #source = https://iopscience.iop.org/article/10.1086/375776/pdf Fig 15
    mchar = -20.67
    alpha = -1.20
    phi_star = 1.46e-2

    phi = np.log(10)*phi_star*(10.**(0.4*(alpha+1)*(abs_mag - mchar)))*np.exp(-10.**(0.4*(abs_mag-mchar)))/2.5


    return phi

def testing_mags():
    
    #overestimating z here by overestiating the dist
    d_overest = 500.
    c = 2.99e5
    z_overest = (d_overest*100.)/c 
    z = np.arange(0., z_overest, 0.01)
    d = z*c/100.
    print(d[0])

    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r =  model.get_observed_absolute_mags(3.0, filters = "sloan_r", zs = z, ab = True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters = "ks", zs = z, vega = True)
    rminusk = abs_mag_r - abs_mag_ks
    

    #assuming a Ks_thresh = 11.25, obtaining the r threshold at various z
    r_thresh = 11.25 + rminusk 
    r_thresh_up = 14.7
    Mr_thresh_up = r_thresh_up - 25. - 5.*np.log10(d)
    Mr_thresh = r_thresh - 25. - 5.*np.log10(d)

    print("Here")

    fig, [ax1, ax2] = plt.subplots(1,2)
    ax1.plot(z, r_thresh)
    ax1.set_xlabel(r"z")
    ax1.set_ylabel(r"r")
    ax2.plot(z, Mr_thresh_up)
    ax2.plot(z, Mr_thresh, color = "tab:red")
    ax2.set_xlabel(r"z")
    ax2.set_ylabel(r"Mr")
    plt.show()
    
    
    
def number_den_hod(path):
    f = h5py.File(path, "r")
    abs_mag = f["abs_mag"][:]
    print("Original number of galaxies")
    print(len(abs_mag))
    z = f["zcos"][: ]
    
    model = ezgal.model('bc03_ssp_z_0.02_salp.model')
    abs_mag_r = model.get_observed_absolute_mags(3.0, filters = "sloan_r", zs = z, ab = True)
    abs_mag_ks = model.get_observed_absolute_mags(3.0, filters = "ks", zs = z, vega = True)
    rminusk = abs_mag_r - abs_mag_ks
    abs_mag_k = abs_mag - rminusk #adding the r-k correction to r magntidues
    

    #--------------------------------------------------------------------
    #obtaining the apparent k band magnitudes 
    #transforming the simulation box first to MW as origin 
    pos = f["pos"][:]
    x = pos[:,0]; y = pos[:,1]; z = pos[:,2]
    
    
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

    K = abs_mag_k + 25. + 5.*np.log10(d)
    #-----------------------------------------------------------------------
    #obtaining the galaxies within 11.25 
    w  = np.where(K < 11.25)[0]
    print("Final number of galaxies")
    print(len(w))




def box_slices(path):
    f = h5py.File(path, "r")
    d = f["sim1"]
    pos = d["pos"]
    vel = d["vel"][:]
    x = pos[:, 0]; y = pos[:, 1]; z = pos[:, 2]
    interval = 25.
    uplim = 500. + interval
    zbins = np.arange(0., uplim, interval)
    xbins = np.arange(0., uplim, interval)
    ybins = np.arange(0., uplim, interval)
    print(zbins)
    
    
    for j in range(len(zbins)-1):
        zlo = zbins[j]
        #print("zlo")
        #print(zlo)
        zhi = zbins[j+1]
        #print("zhi")
        #print(zhi)
        w = np.where((z > zlo) & (z <= zhi))[0]

        #galaxies that belong to this slice
        xthis = x[w]
        ythis = y[w]
        velthis = vel[w]

        #initalizing an array that will store the veldisp 
        #for each bin in the slice
        veldisp = np.zeros((len(xbins), len(ybins)))
        
        for k in range(len(xbins)-1):
            xlo = xbins[k]
            #print("Xlo")
            #print(xlo)
            xhi = xbins[k+1]
            #print("Xhi")
            #print(xhi)
            wx = np.where((xthis > xlo) & (xthis <= xhi))[0]
            #obtaining the corresponding galaxies
            ythisthis = ythis[wx]
            velthisthis = velthis[wx]
            
            
            
            
            for l in range(len(ybins)-1):
                ylo = ybins[l]
                yhi = ybins[l+1]
                wfinal = np.where((ythisthis > ylo) & (ythisthis < yhi))[0]
                
                velthis_bin = vel[wfinal]
                velthisx = velthis[:,0]; velthisy = velthis[:, 1]; velthisz = velthis[:,2]
                velthis_tot = np.sqrt(velthisx**2 + velthisy**2 + velthisz**2)
                velthis_disp = np.std(velthis_tot)
                
                veldisp[k, l] = velthis_disp
             
        print(zhi)
        
        xbins_mesh, ybins_mesh = np.meshgrid(xbins, ybins, indexing = "ij")
        fig, ax = plt.subplots()
        im = ax.pcolormesh(xbins,  ybins, veldisp)
        plt.colorbar(im)
        plt.savefig("../plots/slice" + np.str(j) + ".png")
        

def random_draw(path_to_mockcat, path_to_sim):
    #This function definition will randomly draw a position in the simulation box, check the number of 
    #galaxies around that position and if they are equal to the number of galaxies we had 
    #originally, then go ahead and compute the velocity dispersion

    #collect the positions of the galaxies in the mock cat
    f = h5py.File(path_to_mockcat, "r")
    sim1_mock = f["sim1"]
    posMock = sim1_mock["pos"][:]
    posxMock = posMock[:,0]; posyMock = posMock[:,1]; poszMock = posMock[:,2] 
    
    #collecting the positions of halos and subhalos 
    snaps = glob.glob(directory + "/snapdir*")
    s = len(snaps) - 1
    cat = readsubf.subfind_catalog(directory, s, subcat = True, grpcat = True, 
                                   keysel=['GroupPos', 'GroupVel',
                                           'SubhaloVel', 'SubhaloPos'])
    treeMock = KDTree(posMock)
    treeSim = KDTree(posSim)

    count = 0.
    dist_search = 8.
    dispSim = []; dispMock = []; pos_ar - []

    while count < 1000:
        ranX = np.random.uniform(0., 500.); ranY = np.random.uniform(0., 500.)
        ranZ = np.random.uniform(0., 500.)
        ranPos = [ranX, ranY, ranZ]
        
        iSim = treeSim.query_ball_point(ranPos, dist_search)
        iMock = treeMock.query_ball_point(ranPos, dist_search)
        
        if len(iSim) == len(iMock): 
            continue 
        else:
            count += 1
            
            velSim_this = velSim[iSim]; velMock_this = velMock[iMock]
            velSim_this = np.sqrt(velSim_this[:,0]**2 + velSim_this[:,1]**2 + velSim_this[:,2]**2)
            velMock_this = np.sqrt(velMock_this[:,0]**2 + velMock_this[:,1]**2 + velMock_this[:,2]**2)
            dispSim = np.std(velSim_this); dispMock = np.std(velMock_this)
        
            dispSim_ar.append(dispSim); dispMock_ar.append(dispMock)
            pos_ar.append(ranPos)
            

def readFile(path):
    f = h5py.File(path)
    keys = f.keys()
    hodDict = {}
    for j in range(len(keys)):
        hodDict[keys[j]] = f[keys[j]][:]

    return hodDict


def readSimCat(path_to_file):
    snaps = glob.glob(path_to_file + '/snapdir*')
    s = len(snaps) - 1
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
                                           'GroupPos',
                                           'Group_M_Mean200'])

    return cat

def Nsubs(sim800, hod800, sim1600, hod1600):
    simCat800 = readSimCat(sim800)
    simCat1600 = readSimCat(sim1600)
    hodDict800 = readFile(hod800)
    hodDict1600 = readFile(hod1600)
    haloTest = 10000
    nSim1600 = np.where(simCat1600.SubhaloGrNr == haloTest)[0]
    nHod1600 = np.where(hodDict1600["halo_ind"] ==  haloTest)[0]
    haloPosSim1600 = simCat1600.GroupPos[haloTest]
    haloMassSim1600 = simCat1600.Group_M_Mean200[haloTest]
    print(haloPosSim1600)
    print(haloMassSim1600)
    haloMassHod1600 = hodDict1600["halo_mass"][nHod1600[0]]
    print(haloMassHod1600)

    nSim800 = np.where(simCat800.SubhaloGrNr == haloTest)[0]
    haloMassSim800 = simCat800.Group_M_Mean200[haloTest]
    print(haloMassSim800)
    haloTest800 = np.where(np.all(simCat800.GroupPos == haloPosSim1600, axis = 1))
    print(haloTest800)
    

if __name__ == "__main__":
    path_to_targetlf = "../data/target_lf.dat"
    pathTo800After = "../data/800/mock_cat_debuged.hdf5"
    pathTo800Before = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/800/cat_snapshot_observed.hdf5"
    pathTo1600After = "../data/1600/mock_cat_debuged.hdf5"
    pathTo1600Before = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/1600/cat_snapshot_observed.hdf5"

    #paths = [path_to_hodoutput_1600, path_hodcat]
    #paths = [path_to_hodoutput_1600, path_to_hodoutput_800]
    paths = [pathTo800Before, pathTo800After, pathTo1600Before, pathTo1600After]
    lumfunc(path_to_targetlf, paths)


    #testing_mags()
    #box_slices(path_to_hodoutput_800)
    #number_den_hod(path_hodcat)

    '''
    sim800 = "/home/shivani.shah/Projects/LIGO/runs/Round6/run1/output"
    sim1600 = "/home/shivani.shah/Projects/LIGO/runs/Round8/run1/output"
    hod800 = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/800/cat_snapshot_observed.hdf5"
    hod1600 = "/home/shivani.shah/shahlabtools/Python/hod_new/hod/output/1600/cat_snapshot_observed.hdf5"
    Nsubs(sim800, hod800, sim1600, hod1600)
    '''
