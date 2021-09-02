from mpi4py import MPI
import numpy as np

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()   
print(size)
numDataPerRank = 10  
#sendbuf = np.linspace(rank*numDataPerRank+1,(rank+1)*numDataPerRank,numDataPerRank)
#sendbuf = np.linspace(1,4,3)
sendbuf = np.array([[rank,rank], [rank+5,rank+5], [rank+10,rank+10]])
print('Rank: ',rank, ', sendbuf: ',sendbuf)
'''
recvbuf = None
if rank == 0:
    recvbuf = np.empty(3*size, dtype = "int")  
    #recvbuf = np.empty(6, dtype = "d")
'''
d = np.array(comm.gather(sendbuf, root=0))
#d = np.array([d,d])
#print(np.shape(d))
#d = np.concatenate(d, axis = 0)
if rank == 0:
    #print('Rank: ',rank, ', recvbuf received: ',recvbuf)
    print(d)
    print("-------------")
    d = np.concatenate(d)
    print(d)
