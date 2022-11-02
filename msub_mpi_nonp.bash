#!/bin/bash
#PBS -l nodes=6:ppn=20
#PBS -l walltime=7:00:00:00
#PBS -o outputfile
#PBS -e errorfile
#PBS -V
#PBS -N simulation_tri
cd /home/zhanglei/code_lms_lei/Cedar_code/Modeling_ns_const_dc_oblique
mpirun -n 120 ./3d_triangular_oblique_ns 
