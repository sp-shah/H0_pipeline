FUNCTION VolSphereSeg, radius, FRAC=VolFrac, DISTCUT=DistCut
   ; Compute the volume of a sphere with a segment missing such that
   ; the volume is only VolFrac of sphere volume inside D<DistCut
 
   Vol = VolSphere(radius)
   IF N_ELEMENTS(DistCut) EQ 0 THEN RETURN, Vol
   
   IF radius LE DistCut THEN RETURN, Vol*VolFrac
   IF radius GT DistCut THEN BEGIN
       Vol1 = VolSphere(DistCut)
       RETURN, Vol + Vol1*(VolFrac-1)
   ENDIF

END
