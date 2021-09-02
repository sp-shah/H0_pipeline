#!/bin/bash					
#SBATCH -J HOD1
#SBATCH --mem-per-cpu=6000
#SBATCH --time=50:00:00
#SBATCH --mail-user=shivani.shah@ufl.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=hpg2-compute
#SBATCH --ntasks=70
#SBATCH --ntasks-per-socket=16
#SBATCH --distribution=cyclic:cyclic
#SBATCH --cpus-per-task=1
#SBATCH --qos=paul.torrey


module purge
module load conda
source activate py27


mpiexec -n 70 python mock_cat1.py 1> output1/OUTPUT 2> output1/ERROR
