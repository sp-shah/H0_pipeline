import numpy as np
from mpi4py import MPI
import sys
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

if rank == 0:
    class Myclass:
        hodDict = dict(x = [1,1], y = [2,2])

    myObject = Myclass()

myObject = comm.bcast(myObject)
myObject.hodDict[x][rank] = 100+rank

myObject = comm.gather(myObject, root = 0)
if rank ==0:
    print(myObject.hodDict)

