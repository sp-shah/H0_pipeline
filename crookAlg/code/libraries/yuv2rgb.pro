PRO YUV2RGB, Y, U, V, R255, G255, B255
; Y [0,1]
; U [-0.436,0.436]
; V [-0.615,0.615]

   R = Y + 1.13983*V
   G = Y - 0.39465*U - 0.58060*V
   B = Y + 2.03211*U

   R255 = R*255
   G255 = G*255
   B255 = B*255
END