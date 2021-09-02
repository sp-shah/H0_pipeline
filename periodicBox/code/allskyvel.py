#################################################################################33
# This code can map the velocity/velocity dispersion over the entire sky at a fixed distance
# using nearest 100 subhalos
#
#
#
##################################################################################3
import numpy as np
import matplotlib
matplotlib.use('agg')
from matplotlib import pyplot as plt
import simread.readsubfHDF5 as readsubf
import simread.readhaloHDF5 as readhalo
import simread.readsnapHDF5 as readsnap
import glob
import sys
import matplotlib
import matplotlib.cm as cm
from scipy.spatial import cKDTree
from cat import cat
from scipy.stats import norm
import matplotlib.mlab as mlab
from grid import grid
from scipy.optimize import curve_fit


def gaussian(x, mu, amplitude,sigma):
    return amplitude*np.exp(-((x-mu)/sigma)**2)


def plotvel_real(kn,runs,data_com, ra_gen, dec_gen, num):

    for i in range(len(runs)):
        x, y, z, vx, vy, vz,mass = cat(runs[i], mass_cutoff)
        
        if i == 0:
            xar = np.array(x); yar = np.array(y); zar = np.array(z); vxar = vx; vyar = vy; vzar = vz; massar = mass
        else:
            xar = np.append(xar, x); yar = np.append(yar, y); zar = np.append(zar, z)
            vxar = np.append(vxar, vx); vyar = np.append(vyar, vy); vzar = np.append(vzar, vz)
            massar = np.append(massar, mass)
    
    

            
    data =  np.stack([xar,yar,zar], axis = 1)
    
    tree = cKDTree(data)
    d, ii = tree.query(data_com, k = kn, distance_upper_bound = 15.)
    d = np.array(d)
    ii = np.array(ii)
    
    mu_ar = []
    sigma_ar = []
    delar = []
    for row in range(len(d[:,1])):
        
        #Deleting the infinity terms
        drow = d[row,:]
        iirow = ii[row, :]
        w = np.where(drow == np.float('inf'))
        dnew = np.delete(drow, w)
        iinew = np.delete(iirow, w)
        
        if np.size(dnew) == 0:
            mu_ar.append(np.nan)
            sigma_ar.append(np.nan)
            continue
        else:
            #Averaging the peculiar velocities and obtaining the SD 
            velx = vxar[iinew]
            vely = vyar[iinew]
            velz = vzar[iinew]
            posx = xar[iinew]
            posy = yar[iinew]
            posz = zar[iinew]
        
            posr = np.sqrt(posx**2 + posy**2 + posz**2)
            
            vrad = velx*posx + vely*posy +velz*posz
            vrad /= posr
        
            mu = np.mean(vrad)
            sigma = np.sqrt(np.var(vrad))
            #(mu, sigma) = norm.fit(vrad)
            mu_ar.append(mu)
            sigma_ar.append(sigma)
            
   
    #ra_gen = np.delete(ra_gen, delar)
    #dec_gen = np.delete(dec_gen,delar)
    
    phi = ra_gen
    theta = dec_gen
    mu_ar = np.ma.array(mu_ar, mask = np.isnan(mu_ar))
    mu_ar = np.reshape(mu_ar, (num,num))
    sigma_ar = np.ma.array(sigma_ar, mask = np.isnan(sigma_ar))
    sigma_ar = np.reshape(sigma_ar, (num, num))
    cmap = matplotlib.cm.bwr
    cmap.set_bad("grey", 1)
    

    fig = plt.figure(1)
    ax = fig.add_subplot(111, projection="mollweide")
    
    #extent = (-np.pi, np.pi, -np.pi/2, np.pi/2)
    im = ax.pcolormesh(phi, theta, sigma_ar, cmap = cmap)
    
    #plt.grid(True)
    #plt.scatter(phi, theta, c=mu_ar, cmap = "bwr")
    #plt.colorbar()
    #plt.title("$Averaged Velcotity(\theta,\phi$) km/s")
    cbar = fig.colorbar(im)
    cbar.set_label('[km/s]')
    plt.title('1 $\sigma$ dispersion in ')
    
    plt.show()
    
#########################################################################################################################################
#RED_SHIFT SPACE

def plotvel_z(runs, data_com_vel,**kwargs):


    if ("data_com_z" in kwargs): data_com_z = kwargs["data_com_z"]
    if ("num" in kwargs): num = kwargs["num"]
    if ("mass_cutoff" in kwargs): mass_cutoff = kwargs["mass_cutoff"]
        
    if ("sigma_lo" in kwargs): sigma_lo = kwargs["sigma_lo"]
    if ("sigma_up" in kwargs): sigma_up = kwargs["sigma_up"]
    if ("vel_upper_bound" in kwargs): vel_upper_bound = kwargs["vel_upper_bound"]
    if ("kn" in kwargs): kn = kwargs["kn"]
        
    if ("ra_gen" in kwargs): ra_gen = kwargs["ra_gen"]
    if ("dec_gen" in kwargs): dec_gen = kwargs["dec_gen"]
    if ("cluster" in kwargs): cluster = kwargs["cluster"]

    #read off the data from all the runs and obtain arrays of positions, velocities and mass
    for i in range(len(runs)):
        x, y, z, vx, vy, vz,mass = cat(runs[i], mass_cutoff)
        
        if i == 0:
            xar = np.array(x); yar = np.array(y); zar = np.array(z); vxar = vx; vyar = vy; vzar = vz; massar = mass
        else:
            xar = np.append(xar, x); yar = np.append(yar, y); zar = np.append(zar, z)
            vxar = np.append(vxar, vx); vyar = np.append(vyar, vy); vzar = np.append(vzar, vz)
            massar = np.append(massar, mass)
        
    
    #Obtaining the Hubble red-shift and Hubble velocity
    d = np.sqrt(xar**2 + yar**2 + zar**2) #distance to various objects from the origin
    c = 2.98e5 #speed of light in km/s
    v_H = 100. * d #Hubble flow velocity 
    z_H = v_H/c
    
    #Obtaining line of sight peculiar velocity and the corresponding red-shit
    v_pec = vxar*xar + vyar*yar + vzar*zar
    v_pec /= d
    z_pec = v_pec/c


    #Obtaining the final red-shit and velocity along line of sight
    zt = ((1+z_H)*(1+z_pec))-1
    vt = zt*c

    
    
    #Converting the cartesian coordinates to spherical (ra, dec, d)
    phi = np.arctan2(yar,xar)
    theta = np.arcsin(zar/d)

    #Using angular spherical coordinates (ra, dec) and total red-shift to obtain the cartesian coordinates in red-shift space
    x_zspace = zt*np.cos(theta)*np.cos(phi)
    y_zspace = zt*np.cos(theta)*np.sin(phi)
    z_zspace = zt*np.sin(theta)
    
    #Using angular spherical coordinates (ra, dec) and total red-shift to obtain the cartesian coordinates in velocity-shift space
    x_vspace = vt*np.cos(theta)*np.cos(phi)
    y_vspace = vt*np.cos(theta)*np.sin(phi)
    z_vspace = vt*np.sin(theta)


    #Stacking the data in v-space, creating a tree, quering the tree for nearest objects, obtaining the distances, 
    #and indices of the subhalos in a region of 2000 km/s around the query point
    data =  np.stack([x_vspace,y_vspace,z_vspace], axis = 1)
    tree = cKDTree(data)
    d, ii = tree.query(data_com_vel, k = kn, distance_upper_bound = vel_upper_bound)
    d = np.array(d)
    ii = np.array(ii)
    
    
    #Obtaining the mean of standard deviation of the peculiar velocity distribution of nearest objects for each query point 
    mu_ar = []
    sigma_ar = []
    delar = []
    
    #for row in range(len(d[:,1])):
    for row in range(1):
   
        #Deleting the infinity terms, which are created in case number of objects found < kn
        #drow = d[row,:]
        #iirow = ii[row, :]
        drow = d
        iirow = ii
        w = np.where(drow == np.float('inf'))
        dnew = np.delete(drow, w)
        iinew = np.delete(iirow, w)
        
        if np.size(dnew) < 20:
            mu_ar.append(np.nan)
            sigma_ar.append(np.nan)
            print("no")
            continue
        else:
            #obtaining the line of sight peculiar velocity
            velx = vxar[iinew]
            vely = vyar[iinew]
            velz = vzar[iinew]
            posx = x_vspace[iinew]
            posy = y_vspace[iinew]
            posz = z_vspace[iinew]
            posr = np.sqrt(posx**2 + posy**2 + posz**2)
            vrad = velx*posx + vely*posy +velz*posz
            vrad /= posr

            mu = np.mean(vrad)
            sigma = np.sqrt(np.var(vrad))
            print(sigma)
            print(mu)
            print(np.size(vrad))
            
            '''
            ###using a different method to obtain the distribution of pec vel#######

            #Obtaining the mean and variation
            mean = np.mean(vrad)
            sd = np.sqrt(np.var(vrad))

            #plt.figure()
            bin_heights,bin_borders, _ = plt.hist(vrad,30, density = 1)
            bin_centers = bin_borders[:-1]+np.diff(bin_borders)/2
            w = np.where(bin_centers == np.max(bin_centers))
            amp = bin_heights[w[0]]
            try:
                popt, pcov = curve_fit(gaussian, bin_centers, bin_heights, p0=[mean, amp, sd])
                
            except RuntimeError:
                coxntinue
            
            mu = popt[0]
            sigma = popt[2]
            '''
            #Determining whether it is a good for plotting the trumpet model 
            if sigma > sigma_lo and sigma < sigma_up and np.size(vrad) >=20:
                #print(sigma)
                #print(mu)
                mass = massar[iinew]


                #Determing the line of sight vel in the cluster rest frame
                v = vt[iinew]
                z_red = zt[iinew]
                z_cl = np.mean(z_red)
                delv = c*(z_red - z_cl)
                delv /= (1-z_cl)

                #Obtaining the x-axis as a projection
                x_vpsace = x_vspace[iinew]
                y_vspace = y_vspace[iinew]
                z_vpsace = z_vspace[iinew]
                #for loop in range(len(x_vspace)):
                 #   x = x_vpsace[loop]; y = y_vspace[loop]

                #theta = 
                #r = np.mean(v)*np.tan(theta) 
                
                ########old way####################
                R = np.sum(mass*dnew)/np.sum(mass)
                delr = np.abs(dnew-R)
                deld = delr/100 
                #####################################
                
                plt.figure()
                plt.plot(deld, delv, linestyle = 'none', marker = '*')
                plt.xlabel("Distance from Center of Mass [Mpc]")
                plt.ylabel("$(cz - cz_cl)/(1-z_cl)$")
                plt.title(cluster)
                plt.savefig("plots/coma_cluster_email.pdf")

                sys.exit()
                #####Trying to characterize the caustics#######
                #####Me trying to compute the 1-sigma dispersion in different distance bins#######
                sd_deld_up = []
                sd_deld_lo = []
                deld_bins = []
                interval = np.max(deld)/10.
                mea = []
                sd_deld = []
                for i in range(10):
                    #vrad_deld = vrad[(deld <= interval*(i+1)) & (deld > interval*(i))]
                    #m = np.mean(vrad_deld)
                    #s = np.sqrt(np.var(vrad_deld))
                    
                    delv_deld = delv[(deld <= interval*(i+1)) & (deld > interval*(i))]
                    deld_int = deld[(deld <= interval*(i+1)) & (deld > interval*(i))]
                    s = np.sqrt(np.var(delv_deld))
                    m = np.mean(delv_deld)
                    
                    '''
                    plt.figure()
                    bin_heights,bin_borders, _ = plt.hist(vrad_deld,10, density = 1)
                    bin_centers = bin_borders[:-1]+np.diff(bin_borders)/2
                    w = np.where(bin_centers == np.max(bin_centers))
                    amp = bin_heights[w[0]]
                    try:
                        popt, pcov = curve_fit(gaussian, bin_centers, bin_heights, p0=[m, amp, s])
                        x_interval_for_fit = np.linspace(bin_borders[0], bin_borders[-1], 10000)
                        plt.plot(x_interval_for_fit, gaussian(x_interval_for_fit, *popt), label='fit')
                        plt.title("$\mu=%.2f km/s,\ \sigma=%.2f km/s$" %(popt[0], popt[2]))
                        plt.savefig("plots/batch1/%d.png" %(i))
                        print(i)
                    except RuntimeError:
                        continue
                    
                    sd_deld.append(popt[2])
                    '''
                    sd_deld.append(s)
                    sd_deld_up.append(m+s)
                    sd_deld_lo.append(m-s)
                    deld_bins.append(np.mean(deld_int))
                    mea.append(np.mean(m))
                

                print(sd_deld)
                print(mea)
                print(sd_deld_up)
                print(sd_deld_lo)
                print(deld_bins)
                #sys.exit()
                
                plt.figure()
                #plt.plot(deld, vrad, linestyle = 'none', marker = '*')
                plt.plot(deld, delv, linestyle = 'none', marker = '*')
                plt.plot(deld_bins, sd_deld_up, marker = 'o', color = 'black')
                plt.plot(deld_bins, sd_deld_lo, marker = 'o', color = 'black')
                plt.xlabel("Distance from Center of Mass [Mpc]")
                plt.ylabel("$(cz - cz_cl)/(1-z_cl)$")
                #plt.title("Caustic at z = 0.12")
                plt.title(cluster)
                plt.savefig("plots/caustic"+cluster+"_test.png")
                print("saved")

            else:
                print("Nope")
            
            sys.exit()
            mu_ar.append(mu)
            sigma_ar.append(sigma)
            
            

    mu_ar = np.array(mu_ar)
    sigma_ar = np.ma.array(sigma_ar, mask = np.isnan(sigma_ar))
    #a = (sigma_ar >= 1000.)
    #count = a.sum()
    print(np.max(sigma_ar))


##############################################################################################3
dist_cutoff = 50. #[Mpc]
mass_cutoff = 30. # [solar mass]; 1.e12 solar mass = mass of MW 
s_scale = 7.
kn = 1000
num = 1000
c = 2.99e5
redshift_cutoff = 0.12
vel_cutoff = redshift_cutoff*c 
vel_upper_bound = 2000.
sigma_up = 1500.
sigma_lo = 450.
####################################################################################################
path = "/home/shivani.shah/Projects/LIGO/runs/Round6/"
runs = [path+"run1/output"]#, path+"run2/output", path+"run3/output", path+"run4/output", path+"run5/output", path+"run6/output", path+"run7/output", path+"run8/output"]
######################################################################################################
#data_com, ra_gen, dec_gen  = grid(num, dist_cutoff)
#plotvel_real(kn, runs, data_com, ra_gen, dec_gen, num)

data_com_z, ra_gen, dec_gen = grid(num, redshift_cutoff) #data_com = [x,y,z] stacked, [ra_gen,dec_gen]= meshgrid, num of grid points
data_com_vel, ra_gen, dec_gen = grid(num, vel_cutoff)
plotvel_z(runs, data_com_vel, data_com_z = data_com_z, num = num, cluster = "0p12", mass_cutoff = mass_cutoff, kn = kn, vel_upper_bound= vel_upper_bound,sigma_up=sigma_up, sigma_lo = sigma_lo)
