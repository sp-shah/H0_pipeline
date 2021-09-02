FUNCTION DotProduct, V1, V2, THETA=theta, DELTA=delta
   ; V1 and V2 are (Nx3) arrays of N x 3-element vectors
   ; Compute Dot Product on each V1(i,*) . V2(i,*)

   DP = V1(*,0)*V2(*,0) + V1(*,1)*V2(*,1) + V1(*,2)*V2(*,2)
  
   MagV1 = SQRT(V1(*,0)^2 + V1(*,1)^2 + V1(*,2)^2)
   MagV2 = SQRT(V2(*,0)^2 + V2(*,1)^2 + V2(*,2)^2)

   ; Compute Delta (MagV1-MagV2)
   delta = MagV1 - MagV2
   
   ; Compute theta (angle between 2 vectors)
   theta = ACOS( DP / (MagV1*MagV2) )

   RETURN, DP
   
END
