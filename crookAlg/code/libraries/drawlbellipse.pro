PRO DrawLBEllipse, Lcenter, Bcenter, Lerr, Berr, _EXTRA=extra
   ; Draw an ellipse entered on (Lcenter, Bcenter)
   ; with errors given by Lerr, Berr

   ; Not Correct!!
   EllipseXY, Lerr, Berr, 0, x, y, XCENTER=Lcenter, YCENTER=Bcenter
   
   OPLOT, x, y, _EXTRA=extra

   RETURN


   ProbEllipse = 1 - ERF(1./SQRT(2))

   Nsample = 100

   Lval = NumInRange(Nsample, Lcenter-Lerr, Lcenter+Lerr)
   Bvaloff = NumInRange(Nsample, 0, Berr)

   pL = 1. - ERF( ABS(Lval-Lcenter) / (SQRT(2)*Lerr) )
   pBoff = 1. - ERF( Bvaloff / (SQRT(2)*Berr) )
   
   ; For each Lval, find corresponding Bval for the ellipse
   EllipseL = Lval
   EllipseBoff = INTERPOL(Bvaloff, pBoff, ProbEllipse / pL)

   OPLOT, [EllipseL, REVERSE(EllipseL)], [Bcenter+EllipseBoff, Bcenter-EllipseBoff], _EXTRA=extra

END
