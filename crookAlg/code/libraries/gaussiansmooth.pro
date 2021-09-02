; Smooths a 2-D array by convolving FFT with Gaussian

FUNCTION GaussianSmooth, Image, GAUSSWIDTH=GaussStdDev

   IF NOT KEYWORD_SET(GaussStdDev) THEN GaussStdDev = 1

   psfG = PSF_GAUSSIAN(NPIXEL=20, NDIMEN=2, ST_DEV=GaussStdDev, /NORMALIZE)

   SmoothedImage = CONVOLVE(Image, psfG) 
   
   RETURN, SmoothedImage

END
