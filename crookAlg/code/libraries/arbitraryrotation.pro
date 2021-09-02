; Function to rotate a 3-D vector, V, about 3-D axis vector, A,
; through angle theta (radians)

FUNCTION ArbitraryRotation, V, A, theta
   ; Construct (normalized) unit vector in direction of axis
   AxisVec = A / SQRT(TOTAL(A^2))
   x = AxisVec(0)
   y = AxisVec(1)
   z = AxisVec(2)

   angle = DOUBLE(theta)
   
   ; Rotation Matrix, R
   
   R = [[1 + (1-cos(angle))*(x*x-1),        -z*sin(angle)+(1-cos(angle))*x*y,  y*sin(angle)+(1-cos(angle))*x*z  ], $
        [z*sin(angle)+(1-cos(angle))*x*y,   1 + (1-cos(angle))*(y*y-1),        -x*sin(angle)+(1-cos(angle))*y*z ], $
        [-y*sin(angle)+(1-cos(angle))*x*z,  x*sin(angle)+(1-cos(angle))*y*z,   1 + (1-cos(angle))*(z*z-1)       ]]


   Result = R ## V
   
   RETURN, Result

END

PRO TestRotate

   Axis = [0,1,1]
   V = [1,0,0]
   
   PRINT, ArbitraryRotation(V, Axis, 180*!DTOR)


END
