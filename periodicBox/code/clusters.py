import numpy as np
print("numpy loaded")
import matplotlib
print("matplotlib loaded")
matplotlib.use('agg')
from matplotlib import pyplot as plt
import sys
import matplotlib.cm as cm
from astropy import units as u
from astropy.coordinates import SkyCoord
from matplotlib.axes import Axes
#from cat import cat
#print("Cat loaded")
import allskyvel 
print("allskyvel loaded")
from allskyvel import plotvel_z
print("plotvel_z loaded")



degtorad = np.pi/180.
print(degtorad)

def plot_skymap(phi, theta, masses):

    Fig1 = plt.figure(1)
    plt.subplot(111, projection="hammer")
    plt.grid(True)
    
    # Setting the scale 
    # Set using the log scale of mass in solar mass units
    size = (masses - np.min(masses))*s_scale/(np.max(masses) - np.min(masses))
    scale_r = (r - np.min(r)*s_scale/(np.max(r)) - np.min(r))
    colors = plt.cm.coolwarm(scale_r)

    #####################################################################
    
    #Plotting
    ax = plt.scatter(phi, theta, s = size, label = labels[i],c = r)
    #Axes.invert_yaxis(ax)
    plt.colorbar()



def data(runs, dist_up, dist_lo, mass_cutoff):
    
    #Obtaining the positions, masses and velocities for all the runs 
    for i in range(len(runs)):
        x, y, z, vx, vy, vz,mass = cat(runs[i], mass_cutoff, dist_up = dist_up, dist_lo = dist_lo)
        if i == 0:
            xar = np.array(x); yar = np.array(y); zar = np.array(z); vxar = vx; vyar = vy; vzar = vz; massar = mass
        else:
            xar = np.append(xar, x); yar = np.append(yar, y); zar = np.append(zar, z)
            vxar = np.append(vxar, vx); vyar = np.append(vyar, vy); vzar = np.append(vzar, vz)
            massar = np.append(massar, mass)
    
            
            
    # Assigning the RA and Declination
    r = np.sqrt(x**2 +  y**2 + z**2)
    phi = np.arctan2(y,x)  #RA in radians [-pi,pi]
    theta = np.arcsin(z/r)   #Declination in radians [-pi/2, pi/2]

    return phi, theta, massar

def coma(runs, **kwargs):
    
    if ("dist_up" in kwargs): dist_up = dist_up
    if ("dist_lo" in kwargs): dist_lo = dist_lo
    
    ###########DEFINING THE POSITION####################################
    c = 2.99e5 #km/s
    zred = 0.0208
    #zred = 0.0219
    vel = zred*c
    dist = 288 #Mly ###CONVERT THIS####
    ra = 92.2*degtorad #RA in radians [-pi, pi] 
    dec = -10*degtorad #Dec in radians [-pi/2, pi/2]
    #ra = 89.6*degtorad 
    #dec = 8.2*degtorad
    if ra > np.pi:
        ra -= 2*np.pi 

    ##############PLOT SKYMAP#########################################33
    #phi,theta,massar = data(runs, dist_up, dist_lo, mass_cutoff)
    #plot_skymap(phi,theta,massar)

    #mass = np.log(1.e14/solarmass)
    #plt.scatter(eridanus_ra, eridanus_dec, s = 18.,color = 'royalblue', label = 'Eridanus Cluster', marker = '*', target = 'Fig1')

    ############CAUSTIC####################################################
    vel_upper_bound = 1000. 
    kn = 1000 
    mass_cutoff = 30. 
    x = vel*np.cos(dec)*np.cos(ra)
    y = vel*np.cos(dec)*np.sin(ra)
    z = vel*np.sin(dec)
    data_com_vel = [x,y,z]
    sigma_up = 1500.
    sigma_lo = 150.
    
    plotvel_z(runs, data_com_vel, mass_cutoff = mass_cutoff, kn = kn, vel_upper_bound = vel_upper_bound, sigma_up = sigma_up, sigma_lo = sigma_lo, cluster = 'coma')



def eridanus(runs, **kwargs):
    
    ###########DEFINING THE POSITION####################################
    c = 2.99e5 #km/s
    #z = 
    v = z*c
    #dist = 
    ra = 80.84*degtorad #RA in radians [-pi, pi] 
    dec = -82.55*degtorad #Dec in radians [-pi/2, pi/2]
    if ra > np.pi:
        ra -= 2*np.pi 




def coma(runs, **kwargs):
    
    if ("dist_up" in kwargs): dist_up = dist_up
    if ("dist_lo" in kwargs): dist_lo = dist_lo
    
    ###########DEFINING THE POSITION####################################
    c = 2.99e5 #km/s
    zred = 0.0208
    #zred = 0.0219
    vel = zred*c
    dist = 288 #Mly ###CONVERT THIS####
    ra = 92.2*degtorad #RA in radians [-pi, pi] 
    dec = -10*degtorad #Dec in radians [-pi/2, pi/2]
    #ra = 89.6*degtorad 
    #dec = 8.2*degtorad
    if ra > np.pi:
        ra -= 2*np.pi


    ############CAUSTIC####################################################
    vel_upper_bound = 1000. 
    kn = 1000 
    mass_cutoff = 30. 
    x = vel*np.cos(dec)*np.cos(ra)
    y = vel*np.cos(dec)*np.sin(ra)
    z = vel*np.sin(dec)
    data_com_vel = [x,y,z]
    sigma_up = 1500.
    sigma_lo = 150.
    plotvel_z(runs, data_com_vel, mass_cutoff = mass_cutoff, kn = kn, vel_upper_bound = vel_upper_bound, sigma_up = sigma_up, sigma_lo = sigma_lo, cluster = 'coma')


def cluster_caustic(runs, **kwargs):
    
    if ("dist_up" in kwargs): dist_up = kwargs["dist_up"]
    if ("dist_lo" in kwargs): dist_lo = kwargs["dist_lo"]
    if ("ra" in kwargs): ra = kwargs["ra"]
    if ("dec" in kwargs): dec = kwargs["dec"]
    if ("cluster_name" in kwargs): cluster_name = kwargs["cluster_name"]
    if ("z" in kwargs): zred = kwargs["z"]
    if ("dist" in kwargs): dist = kwargs["dist"]
    
    ###########DEFINING THE POSITION####################################
    print("Defining the position...")
    c = 2.99e5 #km/s
    vel = zred*c
    ra *= degtorad 
    dec *= degtorad
    if ra > np.pi:
        ra -= 2*np.pi


    ############CAUSTIC####################################################
    print("Caustics.....")
    vel_upper_bound = 2000. 
    kn = 1000 
    mass_cutoff = 30. 
    x = vel*np.cos(dec)*np.cos(ra)
    y = vel*np.cos(dec)*np.sin(ra)
    z = vel*np.sin(dec)
    data_com_vel = [x,y,z]
    sigma_up = 1500.
    sigma_lo = 40.
    print("Onto plotvel_z......")
    plotvel_z(runs, data_com_vel, mass_cutoff = mass_cutoff, kn = kn, vel_upper_bound = vel_upper_bound, sigma_up = sigma_up, sigma_lo = sigma_lo, cluster = cluster_name)






path = "/home/shivani.shah/Projects/LIGO/runs/Round6/"
runs = [path+"run1/output", path+"run2/output", path+"run3/output"]
print(path)


#A1367
coma_ra = 235.3140
coma_dec = 73.0142
coma_z = 0.0225
coma_name = " Coma Cluster (A1367)"
#A1656
comatwo_ra = 58.0791
comatwo_dec = 87.9577 
comatwo_z = 0.0234
comatwo_name = "comatwo"
#A2199
hercules_ra = 62.8971
hercules_dec = 43.697
hercules_z = 0.0309
hercules_name = "hercules"
#A426
perseus_ra = 150.5725
perseus_dec = -13.2617
perseus_z = 0.0179
perseus_name = "perseus"
#A4038
a4038_ra = 24.8894
a4038_dec = -75.8166
a4038_z = 0.0288#0.03028
a4038_name = "ACO4038"
#A2151
herculestwo_ra = 31.5878
herculestwo_dec = 44.5216
herculestwo_z = 0.036892
herculestwo_name = "herculestwo"

print("About to call cluster_caustic......")
cluster_caustic(runs, ra = coma_ra, dec = coma_dec, z = coma_z, cluster_name = coma_name)
#cluster_caustic(runs, ra = comatwo_ra, dec = comatwo_dec, z = comatwo_z, cluster_name = comatwo_name)
#cluster_caustic(runs, ra = hercules_ra, dec = hercules_dec, z = hercules_z, cluster_name = hercules_name)
#cluster_caustic(runs, ra = perseus_ra, dec = perseus_dec, z = perseus_z, cluster_name = perseus_name)
#cluster_caustic(runs, ra = a4038_ra, dec = a4038_dec, z = a4038_z, cluster_name = a4038_name)
#cluster_caustic(runs, ra = herculestwo_ra, dec = herculestwo_dec, z = herculestwo_z, cluster_name = herculestwo_name)


#http://www.atlasoftheuniverse.com/nearsc.html
