#!/bin/bash					
#SBATCH -J HOD0
#SBATCH --mem-per-cpu=6000
#SBATCH --time=48:0:00
#SBATCH --mail-user=shivani.shah@ufl.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=hpg2-compute
#SBATCH --ntasks=100
#SBATCH --ntasks-per-socket=16
#SBATCH --distribution=cyclic:cyclic
#SBATCH --cpus-per-task=1
#SBATCH --qos=paul.torrey


module purge
module load conda
source activate py27


mpiexec -n 100 python mock_cat0.py 1> output/OUTPUT 2> output/ERROR

