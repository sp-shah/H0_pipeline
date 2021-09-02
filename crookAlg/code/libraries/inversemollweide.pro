; Computes the values of phi, lambda, given, x, y, lambda0

PRO InverseMollweide, x, y, lambda0, phi, lambda
   theta = ASIN(y/SQRT(2))
   phi = !RADEG*ASIN((2*theta + SIN(2*theta))/!PI)
   lambda = lambda0 + !RADEG*!PI*x / (2*SQRT(2)*COS(theta))
END
