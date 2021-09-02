import sci_funcdef as fd
from mpi4py import MPI


comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()


def main():
    
    fd.ratios(comm, rank, size)




if __name__ == "__main__":
    main()
