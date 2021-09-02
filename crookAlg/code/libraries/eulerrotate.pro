; Projects a 3-D distribution onto a 2-D plane.
; Rotates through euler angles Phi, Theta, Psi (defined on Mathworld)

PRO EulerRotate, x, y, z, xnew, ynew, znew, phi, theta, psi
   D = [[COS(phi),-SIN(phi),0],[SIN(phi),COS(phi),0],[0,0,1]]
   C = [[1,0,0],[0,COS(theta),-SIN(theta)],[0,SIN(theta),COS(theta)]]
   B = [[COS(psi),-SIN(psi),0],[SIN(psi),COS(psi),0],[0,0,1]]

   A = B # (C # D)

   p = TRANSPOSE([[x],[y],[z]])

   pNew = A # p

   xnew = pnew(0,*)
   ynew = pnew(1,*)
   znew = pnew(2,*)

END
