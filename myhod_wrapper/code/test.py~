import simread.readsubfHDF5 as readsubf
import h5py
import sys
from astropy.coordinates import SkyCoord
from astropy import units as u
import numpy as np
import os
import glob

path_to_file = "/home/shivani.shah/Projects/LIGO/runs/Round6/run1/output"

snaps = glob.glob(path_to_file+"/snapdir*")
s     = len(snaps) - 1
cat   = readsubf.subfind_catalog(path_to_file, s, subcat = True, grpcat = True,
                                   keysel = ['SubhaloVel','SubhaloPos'])

x = cat.SubhaloPos[:,0]
y = cat.SubhaloPos[:,1]
z = cat.SubhaloPos[:,2]

#shift xyz positions
x -= (370.)
y -= (370.)
z -= (30.)

#rotate xyz positions
phinot = (39.*np.pi/180.)
x = np.cos(phinot)*x + np.sin(phinot)*y + 0*z
y = -np.sin(phinot)*x + np.cos(phinot)*y + 0*z
z = z
    
d = np.sqrt(x**2 + y**2 + z**2)

#ra, dec in icrs coordinates
ra = np.arctan2(y,x)  #RA in radians [-pi,pi]
dec = np.arcsin(z/d)   #Declination in radians [-pi/2, pi/2]


#ra, dec in galactic coordinates
c_icrs = SkyCoord(ra=ra*u.radian, dec=dec*u.radian, frame='icrs')
l = np.array(c_icrs.galactic.l)
b = np.array(c_icrs.galactic.b)

degtorad = np.pi/180.
l *= degtorad
b *= degtorad


x_gal = d*np.cos(b)*np.sin(l)
y_gal = d*np.cos(b)*np.cos(l)
z_gal = d*np.sin(b)
pos_gal = np.stack((x_gal, y_gal, z_gal), axis = 1)
d_gal = np.sqrt(x_gal**2 + y_gal**2 + z_gal**2)

print(min(x_gal), min(y_gal), min(z_gal))
print(max(x_gal), max(y_gal), max(z_gal))

x_dim = np.abs(min(x_gal)-max(x_gal))
y_dim = np.abs(min(y_gal)-max(y_gal))
z_dim = np.abs(min(z_gal)-max(z_gal))

print(x_dim, y_dim, z_dim)
